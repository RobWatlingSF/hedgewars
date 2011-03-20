{-# LANGUAGE ScopedTypeVariables, OverloadedStrings #-}
module ClientIO where

import qualified Control.Exception as Exception
import Control.Monad.State
import Control.Concurrent.Chan
import Control.Concurrent
import Control.Monad
import Network
import Network.Socket.ByteString
import qualified Data.ByteString.Char8 as B
----------------
import CoreTypes
import RoomsAndClients
import Utils


pDelim :: B.ByteString
pDelim = "\n\n"

bs2Packets = runState takePacks

takePacks :: State B.ByteString [[B.ByteString]]
takePacks
  = do modify (until (not . B.isPrefixOf pDelim) (B.drop 2))
       packet <- state $ B.breakSubstring pDelim
       buf <- get
       if B.null buf then put packet >> return [] else
        if B.null packet then  return [] else
         do packets <- takePacks
            return (B.splitWith (== '\n') packet : packets)

listenLoop :: Socket -> Chan CoreMessage -> ClientIndex -> IO ()
listenLoop sock chan ci = recieveWithBufferLoop B.empty
    where
        recieveWithBufferLoop recvBuf = do
            recvBS <- recv sock 4096
            unless (B.null recvBS) $ do
                let (packets, newrecvBuf) = bs2Packets $ B.append recvBuf recvBS
                forM_ packets sendPacket
                recieveWithBufferLoop newrecvBuf

        sendPacket packet = writeChan chan $ ClientMessage (ci, packet)

clientRecvLoop :: Socket -> Chan CoreMessage -> ClientIndex -> IO ()
clientRecvLoop s chan ci =
        (listenLoop s chan ci >> return "Connection closed") `catch` (return . B.pack . show) >>= clientOff >> remove
    where
        clientOff msg = writeChan chan $ ClientMessage (ci, ["QUIT", msg])
        remove = writeChan chan $ Remove ci



clientSendLoop :: Socket -> ThreadId -> Chan CoreMessage -> Chan [B.ByteString] -> ClientIndex -> IO ()
clientSendLoop s tId cChan chan ci = do
    answer <- readChan chan
    Exception.handle
        (\(e :: Exception.IOException) -> unless (isQuit answer) . killReciever $ show e) $
            sendAll s $ B.unlines answer `B.snoc` '\n'

    if isQuit answer then
        do
        Exception.handle (\(_ :: Exception.IOException) -> putStrLn "error on sClose") $ sClose s
        killReciever . B.unpack $ quitMessage answer
        else
        clientSendLoop s tId cChan chan ci

    where
        killReciever = Exception.throwTo tId . ShutdownThreadException
        quitMessage ["BYE"] = "bye"
        quitMessage ("BYE":msg:_) = msg
        quitMessage _ = error "quitMessage"
        isQuit ("BYE":_) = True
        isQuit _ = False

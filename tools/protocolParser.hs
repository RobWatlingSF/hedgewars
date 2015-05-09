module Main where

import Text.PrettyPrint.HughesPJ
import qualified Data.MultiMap as MM
import Data.Maybe
import Data.List

data HWProtocol = Command String [CmdParam]
data CmdParam = Skip
              | SS
              | LS
              | IntP
              | Many [CmdParam]
data ClientStates = NotConnected
                  | JustConnected
                  | ServerAuth
                  | Lobby

data ParseTree = PTPrefix String [ParseTree]
               | PTCommand HWProtocol

cmd = Command
cmd1 s p = Command s [p]
cmd2 s p1 p2 = Command s [p1, p2]

breakCmd (Command (c:cs) params) = (c, Command cs params)

commands = [
        cmd "CONNECTED" [Skip, IntP]
        , cmd1 "NICK" SS
        , cmd1 "PROTO" IntP
        , cmd1 "ASKPASSWORD" SS
        , cmd1 "SERVER_AUTH" SS
        , cmd1 "JOINING" SS
        , cmd1 "BANLIST" $ Many [SS]
        , cmd1 "JOINED" $ Many [SS]
        , cmd1 "LOBBY:JOINED" $ Many [SS]
        , cmd2 "LOBBY:LEFT" SS LS
        , cmd2 "CLIENT_FLAGS" SS $ Many [SS]
        , cmd2 "LEFT" SS $ Many [SS]
        , cmd1 "SERVER_MESSAGE" LS
        , cmd1 "EM" $ Many [LS]
        , cmd1 "PING" $ Many [SS]
        , cmd2 "CHAT" SS LS
        , cmd2 "SERVER_VARS" SS LS
        , cmd2 "BYE" SS LS
        , cmd1 "INFO" $ Many [SS]
        , cmd "KICKED" []
    ]

groupByFirstChar :: [HWProtocol] -> [(Char, [HWProtocol])]
groupByFirstChar = MM.assocs . MM.fromList . map breakCmd

buildParseTree cmds = [PTPrefix "!" $ bpt cmds]
bpt cmds = if isJust emptyNamed then cmdLeaf $ fromJust emptyNamed else subtree
    where
        emptyNamed = find (\(_, (Command n _:_)) -> null n) assocs
        assocs = groupByFirstChar cmds
        subtree = map buildsub assocs
        buildsub (c, cmds) = let st = bpt cmds in if null $ drop 1 st then maybeMerge c st else PTPrefix [c] st
        maybeMerge c cmd@[PTCommand _] = PTPrefix [c] cmd
        maybeMerge c cmd@[PTPrefix s ss] = PTPrefix (c:s) ss
        cmdLeaf (c, (hwc:_)) = [PTPrefix [c] [PTCommand hwc]]

dumpTree = vcat . map dt
    where
    dt (PTPrefix s st) = text s $$ (nest 1 $ vcat $ map dt st)
    dt _ = empty

pas2 = buildSwitch $ buildParseTree commands
    where
        buildSwitch cmds = text "case getNextChar of" $$ (nest 4 . vcat $ map buildCase cmds) $$ elsePart
        buildCase (PTCommand _ ) = text "#10: <call cmd handler>;"
        buildCase (PTPrefix (s:ss) cmds) = quotes (char s) <> text ": " <> consumePrefix ss (buildSwitch cmds)
        consumePrefix "" = id
        consumePrefix str = (text "consume" <> (parens . quotes $ text str) <> semi $$)
        zeroChar = text "#0: state:= pstDisconnected;"
        elsePart = text "else <unknown cmd> end;"

renderArrays letters commands = l $+$ s
    where
        maybeQuotes s = if null $ tail s then quotes $ text s else text s
        l = text "const letters: array[0.." <> (int $ length letters - 1) <> text "] of char = "
            <> parens (hsep . punctuate comma $ map maybeQuotes letters) <> semi
        s = text "const commands: array[0.." <> (int $ length commands - 1) <> text "] of integer = "
            <> parens (hsep . punctuate comma $ map text commands) <> semi

pas = uncurry renderArrays $ buildTables $ buildParseTree commands
    where
        buildTables cmds = let (_, _, _, t1, t2) = foldr walk (0, [0], -10, [], []) cmds in (tail t1, tail t2)
        walk (PTCommand _ ) (lc, s:sh, pc, tbl1, tbl2) = (lc, 2:sh, pc - 1, "#10":"0":tbl1, "0":(show pc):tbl2)
        walk (PTPrefix prefix cmds) l = lvldown $ foldr fpf (foldr walk (lvlup l) cmds) prefix
        lvlup (lc, sh, pc, tbl1, tbl2) = (lc, 0:sh, pc, tbl1, tbl2)
        lvldown (lc, s1:s2:sh, pc, tbl1, t:tbl2) = (lc, s1+s2:sh, pc, tbl1, show s1:tbl2)
        fpf c (lc, s:sh, pc, tbl1, tbl2) = (lc + 1, s+1:sh, pc, [c]:tbl1, "0":tbl2)

main = putStrLn $ renderStyle style{lineLength = 80} pas
module OfficialServer.DBInteraction
(
	startDBConnection,
	DBQuery(HasRegistered, CheckPassword)
) where

import Database.HDBC
import Database.HDBC.MySQL
import System.IO
import Control.Concurrent
import Control.Exception
import Monad
import Maybe
------------------------
import CoreTypes

dbInteractionLoop queries dbConn = do
	q <- readChan queries
	case q of
		HasRegistered name -> do
			statement <- prepare dbConn "SELECT uid FROM users WHERE name=?"
			execute statement [SqlString name]
			uid <- fetchRow statement
			finish statement
			putStrLn (show $ isJust uid)
		CheckPassword queryStr -> putStrLn queryStr

	dbInteractionLoop queries dbConn

dbConnectionLoop serverInfo = do
	Control.Exception.handle (\e -> print e) $ handleSqlError $
		bracket
			(connectMySQL defaultMySQLConnectInfo {mysqlHost = dbHost serverInfo, mysqlDatabase = "hedge_main", mysqlUser = dbLogin serverInfo, mysqlPassword = dbPassword serverInfo })
			(disconnect)
			(dbInteractionLoop $ dbQueries serverInfo)

	threadDelay (15 * 10^6)
	dbConnectionLoop serverInfo

startDBConnection serverInfo =
	when (not . null $ dbHost serverInfo) ((forkIO $ dbConnectionLoop serverInfo) >> return ())

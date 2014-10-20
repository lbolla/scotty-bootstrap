{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad.IO.Class (liftIO)
-- import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.Logger (runNoLoggingT)
import Controllers.Home (home, login, movies)
-- import Data.Text
-- import Database.Persist.Sqlite (withSqlitePool)
import Database.Persist.Postgresql (withPostgresqlPool, ConnectionString)
-- import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.RequestLogger (logStdout)
import Network.Wai.Middleware.Static (addBase, noDots, staticPolicy, (>->))
import Network.Wai.Middleware.Gzip
import Web.Scotty (middleware, scotty)

import Models.Movies (runDB, mkMoviesDB)

-- dbConnectionString :: Text
-- dbConnectionString = "/tmp/movies.db"
dbConnectionString :: ConnectionString
dbConnectionString = "host=localhost dbname=test user=test password=test port=5432"

dbOpenConnections :: Int
dbOpenConnections = 10

port :: Int
port = 4000

main :: IO ()
-- main = runNoLoggingT $ withSqlitePool dbConnectionString dbOpenConnections $ \pool -> liftIO $ do
main = runNoLoggingT $ withPostgresqlPool dbConnectionString dbOpenConnections $ \pool -> liftIO $ do
    runDB pool $ liftIO $ do
      mkMoviesDB pool
      scotty port $ do
        middleware logStdout
        middleware $ gzip $ def { gzipFiles = GzipCompress }
        middleware $ staticPolicy (noDots >-> addBase "Static")
        home
        movies pool
        login

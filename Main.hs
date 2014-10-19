{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Logger (runStderrLoggingT)
import Controllers.Home (home, login, movies)
import Data.Text
import Database.Persist.Sqlite (withSqlitePool)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.Static (addBase, noDots, staticPolicy, (>->))
import Network.Wai.Middleware.Gzip
import Web.Scotty (middleware, scotty)

import Models.Movies (runDB, mkMoviesDB)

dbConnectionString :: Text
dbConnectionString = ":memory:"

dbOpenConnections :: Int
dbOpenConnections = 10

port :: Int
port = 4000

main :: IO ()
main = runStderrLoggingT $ withSqlitePool dbConnectionString dbOpenConnections $ \pool -> liftIO $ do
    runDB pool $ liftIO $ do
      mkMoviesDB pool
      scotty port $ do
        middleware $ gzip $ def { gzipFiles = GzipCompress }
        middleware logStdoutDev
        middleware $ staticPolicy (noDots >-> addBase "Static")
        home
        movies pool
        login

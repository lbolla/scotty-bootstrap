{-# LANGUAGE OverloadedStrings #-}

module Main where

import Controllers.Home (home, login, movies)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.Static (addBase, noDots, staticPolicy, (>->))
import Web.Scotty (middleware, scotty)
import Database.Persist.Sqlite (withSqlitePool)
import Control.Monad.Logger (runStderrLoggingT)
import Control.Monad.IO.Class (liftIO)

import Models.Movies (runDB, mkMoviesDB)

main :: IO ()
main = runStderrLoggingT $ withSqlitePool ":memory:" 10 $ \pool -> liftIO $ do
    let port = 4000
    runDB pool $ liftIO $ do
      mkMoviesDB pool
      scotty port $ do
        middleware $ staticPolicy (noDots >-> addBase "Static/images") -- for favicon.ico
        middleware logStdoutDev
        home
        movies pool
        login

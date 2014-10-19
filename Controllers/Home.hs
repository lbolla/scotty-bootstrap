{-# LANGUAGE OverloadedStrings #-}

module Controllers.Home
    ( home
    , login
    , movies
    ) where

import Control.Monad.IO.Class (liftIO)
import Data.Pool (Pool)
import Database.Persist.Sqlite hiding (get)
import Models.Movies (getMovies)
import Views.Home (homeView)
import Web.Scotty (ScottyM, get, html, json)

home :: ScottyM ()
home = get "/" homeView

login :: ScottyM ()
login = get "/login" $ html "login"

movies :: Pool SqlBackend -> ScottyM ()
movies pool = get "/movies" $ do
  ms <- liftIO (getMovies pool)
  json ms

{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE EmptyDataDecls    #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs             #-}
{-# LANGUAGE GeneralizedNewtypeDeriving      #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}
module Models.Movies where

import Control.Monad.IO.Class (liftIO)
import Database.Persist
import Database.Persist.Sqlite
import Database.Persist.TH
import Data.Pool (Pool)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Movie json
    title String
    year Int
    rating Int
    -- Implicit primary key
    deriving Show
Actor json
    name String
    surname String
    dob Int
    -- Composite primary key
    Primary name surname
    deriving Show
|]

runDB :: Pool SqlBackend -> SqlPersistT IO a -> IO a
runDB = flip runSqlPool

mkMoviesDB :: Pool SqlBackend -> IO ()
mkMoviesDB = runSqlPool $ do
    runMigration migrateAll
    movieIds <- insertMany movies
    liftIO $ print movieIds
  where movies = [ Movie "Rise of the Planet of the Apes" 2011 77
                 , Movie "Dawn of the Planet of the Apes" 2014 91
                 , Movie "Alien" 1979 97
                 , Movie "Aliens" 1986 98
                 , Movie "Mad Max" 1979 95
                 , Movie "Mad Max 2: The Road Warrior" 1981 100
                 ]

getMovies :: Pool SqlBackend -> IO [Entity Movie]
getMovies = runSqlPool $ selectList [] []

{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty

import Control.Concurrent.MVar
import qualified Data.Map.Strict as M
import Network.HTTP.Types
import Control.Monad.IO.Class
import HeapImpl


type Name = String

type HeapName = String

allHeaps :: M.Map Name [HeapName]
allHeaps = M.fromList
    [ ("Heap1",
        [ "1" , "2" , "3" , "4" , "5" , "6"]
      )
    , ("heap2",
        [ "0" , "5" , "8" , "9" , "1" , "2"]
      )
    , ("heap3",
        [ "7" , "2" , "4" , "1" , "5" , "0"]
      )
    ]

validateName :: Name -> Bool
validateName = const True

validateHeaps :: [HeapName] -> Bool
validateHeaps heaps = length heaps == 6

main :: IO ()
main = do
    heaps' <- newMVar allHeaps

    scotty 3000 $ do

        get "/heaps" $ do
            heaps <- liftIO $ readMVar heaps'
            json heaps

        get "/heaps/:name" $ do
            heaps <- liftIO $ readMVar heaps'
            name <- param "name"
            json $ M.lookup name heaps

        post "/heaps/:name" $ do
            name <- param "name"
            newHeaps <- jsonData
            if not (validateName name && validateHeaps newHeaps)
               then status status400
               else do
                   created <- liftIO $ modifyMVar heaps' $ \heaps ->
                       if M.member name heaps
                          then return (heaps, False) 
                          else return (M.insert name newHeaps heaps, True) 
                   if created
                      then status status200
                      else status status403

        put "/heaps/:name" $ do
            name <- param "name"
            newHeaps <- jsonData
            if not (validateName name && validateHeaps newHeaps)
               then status status400
               else do
                   updated <- liftIO $ modifyMVar heaps' $ \heaps ->
                       if M.member name heaps
                          then return (M.update (\_ -> Just newHeaps) name heaps, True) 
                          else return (heaps, False) 
                   if updated
                      then status status200
                      else status status404

        delete "/heaps/:name" $ do
            name <- param "name"
            liftIO $ modifyMVar_ heaps' $ \heaps ->
                return $ M.delete name heaps


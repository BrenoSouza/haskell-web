{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Scotty

import Control.Concurrent.MVar
import qualified Data.Map.Strict as M
import Network.HTTP.Types
import Control.Monad.IO.Class
import HeapImpl

type Name = String

allArray :: M.Map Name [Int]
allArray = M.fromList
    [ 
      ("array1", [0 , 5 , 8 , 9 , 1 , 2])
    ]

validateName :: Name -> Bool
validateName = const True

validateType :: Name -> Bool
validateType = const True

validateArrays :: [Int] -> Bool
validateArrays arrays = length arrays >= 1

main :: IO ()
main = do
    array' <- newMVar allArray

    scotty 3000 $ do

        get "/arrays" $ do
            array <- liftIO $ readMVar array'
            json array

        get "/arrays/:name" $ do
            array <- liftIO $ readMVar array'
            name <- param "name"
            json $ M.lookup name array

        get "/buildheap/:name/:heapType" $ do
            array <- liftIO $ readMVar array'
            name <- param "name"
            --heapType <- param "heapType"

            -- buildheap heapType name heaps
            --if (heapType == "min") then
            --    array <- HeapImpl.buildHeap (M.! heaps name) LT
            --else do
            --    array <- HeapImpl.buildHeap (M.! heaps name) GT

            json $ M.lookup name array

        post "/heapsort/min/:name" $ do
            array <- liftIO $ readMVar array'
            name <- param "name"
    
            updated <- liftIO $ modifyMVar array' $ \array ->
                if M.member name array
                   then return (M.update (\_ -> Just (HeapImpl.heapSort (array M.! name) LT)) name array, True) 
                   else return (array, False) 
            if updated
                then status status200
                else status status404

        post "/heapsort/max/:name" $ do
            array <- liftIO $ readMVar array'
            name <- param "name"
            
            updated <- liftIO $ modifyMVar array' $ \array ->
                if M.member name array
                    then return (M.update (\_ -> Just (HeapImpl.heapSort (array M.! name) GT)) name array, True) 
                    else return (array, False) 
            if updated
                then status status200
                else status status404
        

        post "/arrays/:name" $ do
            name <- param "name"
            newArrays <- jsonData
            if not (validateName name && validateArrays newArrays)
               then status status400
               else do
                   created <- liftIO $ modifyMVar array' $ \array ->
                       if M.member name array
                          then return (array, False) 
                          else return (M.insert name newArrays array, True) 
                   if created
                      then status status200
                      else status status403

        put "/arrays/:name" $ do
            name <- param "name"
            newArrays <- jsonData
            if not (validateName name && validateArrays newArrays)
               then status status400
               else do
                   updated <- liftIO $ modifyMVar array' $ \array ->
                       if M.member name array
                          then return (M.update (\_ -> Just newArrays) name array, True) 
                          else return (array, False) 
                   if updated
                      then status status200
                      else status status404

        delete "/arrays/:name" $ do
            name <- param "name"
            liftIO $ modifyMVar_ array' $ \array ->
                return $ M.delete name array

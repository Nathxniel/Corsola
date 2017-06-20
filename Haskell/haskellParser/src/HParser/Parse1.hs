module HParser.Parse1
  ( parse1 
  , intersperseMap
  ) where

import Data.List (foldr)
    
intersperseMap :: String -> (String -> [String]) -> [String] -> [String]
intersperseMap d f
  = foldr (\x acc -> (f x) ++ (d:acc)) []

parse1 :: String -> [String]
parse1 xs
  = intersperseMap "\n" words $ lines xs

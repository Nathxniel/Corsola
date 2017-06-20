module HParser.Parse1
  ( parse1 
  , intersperseMap
  , Parser
  ) where

import Data.List (foldr)

type Parser = [String] -> [String]
    
intersperseMap :: String -> (String -> [String]) -> Parser
intersperseMap d f
  = foldr (\x acc -> (f x) ++ (d:acc)) []

parse1 :: Parser
parse1 
  = intersperseMap "\n" words

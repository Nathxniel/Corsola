module HParser.Parse1
  ( parse1 
  ) where

import Data.List (foldr)
    
intersperseMap :: String -> (String -> [String]) -> [String] -> [String]
intersperseMap d f
  = foldr (\x acc -> (f x) ++ (d:acc)) []

{- converts: 
 -
 - file input (type: String)
 - into parse2 input
 -}
-- TODO: make "words" more powerful: (tokenize)
-- put spaces either side of text in brackets
-- put spaces before "--" (single line comments)
-- put spaces  after "}-" ( multi line comments)
parse1 :: String -> [String]
parse1
  = (intersperseMap "\n" words) . lines

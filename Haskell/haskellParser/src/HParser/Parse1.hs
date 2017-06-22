module HParser.Parse1
  ( parse1 
  ) where

import Data.List (foldr)
import Data.Char (isSpace)
    
intersperseMap :: String -> (String -> [String]) -> [String] -> [String]
intersperseMap d f
  = foldr (\x acc -> (f x) ++ (d:acc)) []

{- converts: 
 -
 - file input (type: String)
 - into parse2 input
 -}

{-
 - TODO: make "words" more powerful: (tokenize)
 - put spaces either side of text in brackets
 - put spaces before "--" (single line comments)
 - put spaces  after "}-" ( multi line comments)
 - EXPLOIT TAB CHARACTER OMG
 -}
parse1 :: String -> [String]
parse1
  = (intersperseMap "\n" prepare) . lines

prepare k =
  case k of
    []     -> []
    ' ':xs -> "\t":(words k)
    x:xs   -> words k

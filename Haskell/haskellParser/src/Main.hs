module Main
  ( main
  ) where

import HParser

{-
 - For testing
 - TODO: delete
 -}
import HParser.Parse1
import HParser.Parse2

import System.IO (readFile, writeFile)
import System.Environment
import Control.Monad
import Control.Applicative ((<$>))
import Data.List (lines, unlines)

-- File IO version main
main :: IO ()
main = do
  [readfile, writefile] <- getArgs
  ls <- lines <$> readFile readfile
  -- (writeFile writefile) . unlines . parse $ ls
  (writeFile writefile) . test . parse2 . parse1 $ ls 
    where 
      test = (foldr (\x acc -> (show x) ++ ('\n':acc)) "")


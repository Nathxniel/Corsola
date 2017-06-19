module Main
  ( main
  ) where

import HParser

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
  (writeFile writefile) . unlines . parse $ ls

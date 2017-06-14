import System.IO (readFile, writeFile)
import System.Environment (getArgs)
import Control.Monad
import Control.Applicative 

type Parser = [String] -> [String]

-- File IO version main
main :: IO ()
main = do
  -- get read and write location from program arguments
  [readfile, writefile] <- getArgs
  -- remove extraneous spaces
  ls <- map (unwords . words) . lines <$> readFile readfile
  -- write output to file
  writeFile writefile (unlines . parse $ ls)

-- Terminal version main
--main :: IO ()
--main = do
--  ls <- lines <$> getContents
--  putStrLn . unlines . parse $ ls

{- the parser -}

parse :: Parser
-- parsing single-line comments
parse (('-':'-':_):ss)
  = parse ss
parse (('{':'-':_):ss)
  = comment ss

--empty lines and spaces
parse ("":ss)
  = parse ss
parse a@((' ':_):_)
  = space a 

--function definitions
parse (s:ss)
  = funcdef s : parse ss
parse []
  = []

{-
  helper functions for specific parses
-}

-- multi-line comments
comment :: Parser
comment (("-}"):ss)
  = parse ss
comment ((x:xs):ss)
  = comment (xs:ss)
comment ([]:ss)
  = comment ss
  
-- empty space
space :: Parser
space ((' ':s):ss)
  = parse (s:ss)

-- function definitions
funcdef :: String -> String
funcdef xs
  | isFuncDef xs = []
  | otherwise    = xs
  where
    isFuncDef :: String -> Bool
    isFuncDef (':':':':_)
      = True
    isFuncDef (x:xs)
      = isFuncDef xs
    isFuncDef []
      = False

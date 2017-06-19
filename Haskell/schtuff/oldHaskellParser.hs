import System.IO (readFile, writeFile)
import System.Environment (getArgs)
import Control.Monad
import Control.Applicative 
import Data.Char

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
parse (('-':'-':s):ss)
  = ('-':'-':' ':s) : parse ss
parse (('{':'-':s):ss)
  = comment (s:ss)

--empty lines and spaces
parse ("":ss)
  = parse ss
parse a@((' ':_):_)
  = space a 

--function definitions
parse (s:ss)
  | isFuncDef s = s : processFunction ss
  | otherwise   = parse ss
parse []
  = []

--  helper functions for specific parses


-- strip spaces
strip :: String -> String
strip []
  = []
strip (' ':cs)
  = strip cs
strip (c:cs)
  = c : strip cs

-- multi-line comments
comment :: Parser
comment ([]:ss)
  = comment ss
comment (("-}"):ss)
  = parse ss
comment (('-':'}':s):ss)
  = ('-':'-':' ':s) : parse ss
comment (s:ss)
  | ended     = rest : parse (after:ss)
  | otherwise = ('-':'-':' ':s) : comment ss
  where
    isCommentEnd ('-':'}':xs) before
      = (True, ('-':'-':' ':(reverse before)), xs)
    isCommentEnd (x:xs) before
      = (e || False, b, a)
      where
        (e, b, a) = isCommentEnd xs (x:before)
    isCommentEnd [] before
      = (False, before, [])
    (ended, rest, after) = isCommentEnd s []



-- comment ((x:xs):ss)
--   = comment (xs:ss)
-- comment ([]:ss)
--   = comment ss
  
-- empty space
space :: Parser
space ((' ':s):ss)
  = parse (s:ss)

processFunction :: Parser
processFunction ss
  = pfunc ss []

pfunc [] _
  = []
pfunc ([]:[]:prgm) function
  = pfunc prgm function
pfunc (('-':'-':s):ss) function
  = ('-':'-':' ':s) : pfunc ss function
pfunc (('{':'-':s):ss) _
  = comment (s:ss)
pfunc [p] function
  = (processWhere (reverse function)) ++ (parse [p])
pfunc (p:q:prgm) function
  | isFuncDef q = (processWhere (reverse (p:function))) ++ (parse prgm)
  | otherwise   = pfunc prgm (q:p:function)

processWhere ("":func)
  = processWhere func
processWhere func
  | hasWhere func = pwhere func []
  | otherwise     = func

hasWhere []
  = False
hasWhere (f:func)
  | strip f == "where" = True
  | otherwise          = hasWhere func

pwhere func []
  = "YO":func

-- pwhere (f:func) fn
--   | strip f == "where" = mend (reverse fn) (makeWhereMap func)
--   | otherwise          = pwhere func (f:fn)

--mend function wheremap
--  = concatMap (\f -> concat . (replace wheremap) $ (words f)) function
--  where
--    replace wheremap tokens

-- function definitions
isFuncDef :: String -> Bool
isFuncDef (':':':':_)
  = True
isFuncDef (x:xs)
  = isFuncDef xs
isFuncDef []
  = False

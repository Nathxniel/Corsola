import System.IO (readFile, writeFile)
import System.Environment (getArgs)
import Control.Monad
import Control.Applicative 
import Data.Char
import Data.List
import qualified Data.Set as S

type Parser    = [String] -> [String]
type Block     = [Statement]
data Statement = Fstat (String, String) -- function (lhs, rhs)
               | Fline String           -- line within a function
               | FuncDef String         -- function definitions
               | SLineC String          -- single line comments
               | MLineC String          -- multiline comments
               | MdleStat String        -- module statements
               | ImprtStat String       -- import statements
               | Pattern (Block, Block) -- (body, where clause)  
               deriving (Show)

-- File IO version main
main :: IO ()
main = do
  [readfile, writefile] <- getArgs
  ls <- lines <$> readFile readfile
  (writeFile writefile) . unlines . parse $ ls

{- Utility function:
 -
 - Maps a function over a list adding an element inbetween
 -}
intersperseMap :: String -> (String -> [String]) -> Parser
intersperseMap d f
  = foldr (\x acc -> (f x) ++ (d:acc)) []

{- The Parser
 -
 - Converts lines into readable format
 - Identifies comments and functions
 - Converts
 -}
parse :: Parser
parse ls
  = parse3 . parse2 . parse1 $ ls

{- Converts lines into readable format
 -}
parse1 :: Parser
parse1 
  = intersperseMap "\n" words

parse2 :: [String] -> Block
parse2 tks = 
  case tks of
    []            -> []
    ("\n"):r      -> parse2 r
    ("-}"):r      -> parse2 r
    ('-':'-':t):r -> (fst $ parseSLineC (t:r)) : (parse2.snd.parseSLineC $ (t:r))
    ('{':'-':t):r -> (fst $ parseMLineC (t:r)) : (parse2.snd.parseMLineC $ (t:r))
    ("import"):r  -> (fst $ parseImprtStat r)  : (parse2.snd.parseImprtStat $ r)
    ("module"):r  -> (fst $ parseMdleStat r)   : (parse2.snd.parseMdleStat $ r)
    (t:r)         -> (fst $ parseFunc (t:r))   : (parse2.snd.parseFunc $ (t:r))

parse3 = undefined

parseSLineC :: [String] -> (Statement, [String])
parseSLineC tks
  = (SLineC (unwords $ sline), rest)
  where
    (sline, rest) = break (=="\n") tks 

parseMLineC :: [String] -> (Statement, [String])
parseMLineC tks
  = (MLineC (unwords mline), rest)
  where
  (mline, rest) = break (=="-}") tks 

parseImprtStat = undefined

parseMdleStat = undefined

parseFunc :: [String] -> (Statement, [String])
parseFunc tks
  = pf' tks []
  where
    pf' tks acc =
      case tks of
        []             -> (Fline (unwords acc), [])
        ('-':'-':t):ts -> (Fline (unwords acc), tks)
        ('{':'-':t):ts -> (Fline (unwords acc), tks)
        (t:ts)         -> pf' ts (acc ++ [t])

{-
 -
 -
parseFunc (tk:f:tks)
  = (Func (fn, wr), rest)
  where
    (fn, wr) = pf [] [] tk
    pf f w name
      | f == "::" = pf (FuncDef (
      | 
    
    -- fll is func lhs
    -- flr is func lhs
    -- rest is rest of the stuff
    (fll, flr) = (unwords lhs, unwords rhs)
    (rhs, next) = break (=="where") r
    (lhs, r) = break (=="=") tks


parseFunc tks
  = pf tks [] [] tk

pf a@(tk:"::":tks) fn wr _
  = pf rest ((FuncDef func):fn) wr tk
  where
    (func, rest)
-
-
-}

{-
import System.IO (readFile, writeFile)
import System.Environment (getArgs)
import Control.Monad
import Control.Applicative 
import Data.Char
import Data.List
import qualified Data.Set as S

type Parser    = [String] -> [String]
type Block     = [Statement]
data Statement = Fstat (String, String) -- function (lhs, rhs)
               | Fline String           -- line within a function
               | FuncDef String         -- function definitions
               | SLineC String          -- single line comments
               | MLineC String          -- multiline comments
               | MdleStat String        -- module statements
               | ImprtStat String       -- import statements
               | Pattern (Block, Block) -- (body, where clause)  
               deriving (Show)

-- File IO version main
main :: IO ()
main = do
  [readfile, writefile] <- getArgs
  ls <- readFile readfile
  writeFile writefile (unlines . parse $ ls)

intersperseMap :: String -> (String -> [String]) -> Parser
intersperseMap d f
  = foldr (\x acc -> (f x) ++ (d:acc)) []

parse :: Parser
parse ls
  = parse3 . parse2 . (intersperseMap "\n" words) $ ls

parse3 = undefined

parse2 :: [String] -> Block
parse2 [] = []

parse2 ("\n":tks)
  = parse2 tks
-}

-- parse2 ("-}":tks)
--   = parse2 tks
-- 
-- parse2 (('-':'-':tk):tks)
--   = slinec : parse2 rest
--   where
--     (slinec, rest)
--       = parseSLineC (tk:tks)
-- parse2 (('{':'-':tk):tks)
--   = mlinec : parse2 rest
--   where
--     (mlinec, rest)
--       = parseMLineC (tk:tks)
-- parse2 ("import":tks)
--   = imprtstat : parse2 rest
--   where
--     (imprtstat, rest)
--       = parseImprtStat tks
-- parse2 ("module":tks)
--   = mdlestat : parse2 rest
--   where
--     (mdlestat, rest)
--       = parseMdleStat tks
-- parse2 (tk:tks)
--   = funcstat : parse2 rest
--   where
--     (funcstat, rest)
--       = parseFunc (tk:tks)
-- 
-- parseSLineC :: [String] -> (Statement, [String])
-- parseSLineC tks
--   = (SLineC (unwords $ sline), rest)
--   where
--     (sline, rest) = break (=="\n") tks 
-- 
-- parseMLineC :: [String] -> (Statement, [String])
-- parseMLineC tks
--   = (MLineC (unwords mline), rest)
--   where
--     (mline, rest) = break (=="-}") tks 
-- 
-- parseImprtStat = undefined
-- 
-- parseMdleStat = undefined
-- 
-- parseFunc :: [String] -> (Statement, [String])
-- parseFunc tks
--   = pf' tks []
--   where
--     pf' a@(('-':'-':tk):tks) acc
--       = (Fline (unwords acc), a)
--     pf' a@(('{':'-':tk):tks) acc
--       = (Fline (unwords acc), a)
--     pf' (tk:tks) acc
--       = pf' tks (acc ++ [tk])
--     pf' [] acc
--       = (Fline (unwords acc), [])
-- -}


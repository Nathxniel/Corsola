module HParser.Parse2
  ( parse2
  , Block
  , Statement (..)) where

import Data.List

type Block     = [Statement]
data Statement = SLineC String              -- single line comments
               | MLineC String              -- multiline comments
               | MdleStat String            -- module statements
               | ImprtStat String           -- import statements
               | TypeStat String            -- type or data statements
               | FLine String               -- general function line
               | WLine String               -- general where clause line
               | FuncDef String             -- function definitions
               | FStat ([String], [String]) -- function statments (lhs, rhs)
               | Func (Block, Block)        -- function (body, where clause)
               deriving (Show)

parse2 :: [String] -> Block
parse2 tks = 
  case tks of
    []            -> []
    ("\n"):r      -> parse2 r
    ("-}"):r      -> parse2 r
    ('-':'-':t):r -> p2 parseSLineC (t:r) 
    ('{':'-':t):r -> p2 parseMLineC (t:r) 
    ("import"):r  -> p2 parseImprtStat r  
    ("module"):r  -> p2 parseMdleStat r   
    ("type"):r    -> p2 parseTypeStat r   
    ("data"):r    -> p2 parseTypeStat r   
    (t:r)         -> p2 parseFunc (t:r)   

-- parse2 helper: helps recursively iterate parse2
p2 f a
  = newStmt : parse2 rest
  where
    (newStmt, rest) = f a

parseMultiline tks acc typ =
  case tks of
    []            -> (typ (unwords acc), [])
    ('-':'-':_):_ -> (typ (unwords acc), tks)
    ('{':'-':_):_ -> (typ (unwords acc), tks)
    ("import"):_  -> (typ (unwords acc), tks)
    ("module"):_  -> (typ (unwords acc), tks)
    ("type"):_    -> (typ (unwords acc), tks)
    ("data"):_    -> (typ (unwords acc), tks)
    (t:ts)        -> parseMultiline ts (acc ++ [t]) typ

parseSLineC :: [String] -> (Statement, [String])
parseSLineC tks
  = (SLineC (unwords sline), rest)
  where
    (sline, rest) = break (=="\n") tks 

parseMLineC :: [String] -> (Statement, [String])
parseMLineC tks
  = (MLineC (unwords mline), rest)
  where
    (mline, rest) = break (=="-}") tks 

parseImprtStat :: [String] -> (Statement, [String])
parseImprtStat tks
  = parseMultiline tks [] ImprtStat

parseMdleStat :: [String] -> (Statement, [String])
parseMdleStat tks
  = parseMultiline tks [] MdleStat

parseTypeStat :: [String] -> (Statement, [String])
parseTypeStat tks
  = parseMultiline tks [] TypeStat

parseFunc :: [String] -> (Statement, [String])
parseFunc tks
  = parseMultiline tks [] FLine

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
    ('-':'-':t):r -> (fst $ parseSLineC (t:r)) : (parse2.snd.parseSLineC $ (t:r))
    ('{':'-':t):r -> (fst $ parseMLineC (t:r)) : (parse2.snd.parseMLineC $ (t:r))
    ("import"):r  -> (fst $ parseImprtStat r)  : (parse2.snd.parseImprtStat $ r)
    ("module"):r  -> (fst $ parseMdleStat r)   : (parse2.snd.parseMdleStat $ r)
    ("type"):r    -> (fst $ parseTypeStat r)   : (parse2.snd.parseTypeStat $ r)
    ("data"):r    -> (fst $ parseTypeStat r)   : (parse2.snd.parseTypeStat $ r)
    (t:r)         -> (fst $ parseFunc (t:r))   : (parse2.snd.parseFunc $ (t:r))

parseMultiline :: [String] -> [String] 
                   -> (String -> Statement) -> (Statement, [String])
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

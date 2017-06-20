module HParser.Parse3
  ( parse3
  ) where

import HParser.Parse1 (intersperseMap)
import HParser.Parse2
import HParser.Resource

parse3 :: Block -> Block
parse3 b =
  case b of
    []               -> []
    (SLineC c):bs    -> (SLineC c):(parse3 bs)
    (MLineC c):bs    -> (MLineC c):(parse3 bs)
    (MdleStat m):bs  -> (MdleStat m):(parse3 bs)
    (ImprtStat i):bs -> (ImprtStat i):(parse3 bs)
    (TypeStat t):bs  -> (TypeStat t):(parse3 bs)
    (FLine f):bs     -> (process (prepare f)) ++ (parse3 bs)
    b:bs             -> parse3 bs

{-
 - applies parse1 to unprocessed FLine's contents;
 -  parsing over tokens is easier then strings
 -}
prepare k
  = (intersperseMap "\n" words) $ lines k

{-
 - finishes processing unprocessed FLines
 - from parse2
 -}
process []
  = error "Parse error: empty pattern/function"
process (ftk:ftks)
  = p ftk (ftk:ftks) []
    
{-
 - process helper; distinguishes:
 -
 - function definitions
 - comments
 - function statements (of form _ = _)
 - where clauses
 -
 - from the unprocessed FLines of parse2
 -}
p name tks processed =
  case tks of
    []          -> processed
    (n:"::":ts) -> p' name tks (pFDef name []) processed
    _           -> p' name tks (pFStat name []) processed
    
-- p helper: helps recursively iterate p
p' name tks f acc
  = p name rest (acc ++ [newStmt])
  where
    (newStmt, rest) = f tks

-- processes function definitions
pFDef name fdls ("\n":h:rs)
  | h == name = (FuncDef fdls, h:rs)
  | otherwise = pFDef name (fdls ++ "\n") (h:rs)
pFDef n fdls (x:xs) = pFDef n (fdls ++ x) xs 
pFDef _ fdls []     = (FuncDef fdls, [])
    
-- processes function statements (form: lhs = rhs)
pFStat name racc tks
  = (FStat (lhs, rhs), rest)
  where
    (lhs, r)     = break (=="=") tks
    (rhs, rest)  = pRhs r []
    pRhs ("\n":h:rs) racc
      | h == name   = (racc, h:rs)
      | otherwise   = pRhs (h:rs) (racc ++ ["\n"])
    pRhs (x:xs) racc = pRhs xs (racc ++ [x])
    pRhs [] racc     = (racc, [])

-- process []
--   = error "Parse error: empty pattern/function"
-- process (ftk:ftks)
--   = Func $ p ftk (ftk:ftks) []
--     
-- p name [] acc
--   = (acc, [])
-- p name tks acc
--   = (acc' ++ [FStat (lhs, rhs)], rest)
--   where
--     (lhs, r)     = break (=="=") tks
--     (rhs, cont)  = pRhs r []
--     (acc', rest) = p name cont acc
--     pRhs ("\n":h:rs) racc
--       | h == name   = (racc, h:rs)
--       | otherwise   = pRhs (h:rs) (racc ++ ["\n"])
--     pRhs (x:xs) racc = pRhs xs (racc ++ [x])
--     pRhs [] racc     = (racc, [])

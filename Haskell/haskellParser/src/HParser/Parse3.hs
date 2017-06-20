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
    (FLine f):bs     -> (fst.process $ f):((parse3.snd.process $ f):bs)
    (FLine f):bs     -> (process f) ++ (parse3 bs)
    b:bs             -> parse3 bs

prepare k
  = (intersperseMap "\n" words) $ lines k

process []
  = error "Parse error: empty pattern/function"
process (ftk:ftks)
  = prepare $ p ftk (ftk:ftks) []
    
p name [] acc
  = acc
p name tks acc =
  case tks of
    (n:"::":ts) -> p name $ undefined
    


p name tks acc
  = (FStat (lhs, rhs), rest)
  where
    (lhs, r)     = break (=="=") tks
    (rhs, cont)  = pRhs r []
    (acc', rest) = p name cont acc
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

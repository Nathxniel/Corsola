module HParser.Parse3
  ( parse3
  ) where

import HParser.Parse2
import HParser.Resource

parse3 :: Block -> Block
parse3 b =
  case b of
    []               -> []
    (SLineC c):bs    -> (SLine c):(parse3 bs)
    (MLineC c):bs    -> (MLine c):(parse3 bs)
    (MdleStat m):bs  -> (MdleStat m):(parse3 bs)
    (ImprtStat i):bs -> (ImprtStat i):(parse3 bs)
    (TypeStat t):bs  -> (TypeStat t):(parse3 bs)
    (FLine f):bs     -> (process $ words f):(parse3 bs)

-- p3 :: Block -> 
p3 b acc
  = undefined

process []
  = error "Parse error: empty pattern/function"
process (ftk:ftks)
  = Func (p ftk (ftk:ftks), _)

p name tks
  = Fstat (lhs, rhs) : p name rest
  where
    (lhs, r)    = break (=="=") tks
    (rhs, rest) = undefined --keep going until you see "\n":"keyword in map"
    

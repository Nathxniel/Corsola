module HParser.Resource
  ( prldFuncs
  ) where

--TODO: import this somehow
--import qualified Data.Set as S

type FunctionName = String

-- TODO: complete
--prldFuncs :: S.Set FunctionName
prldFuncs :: [FunctionName]
prldFuncs
  -- = S.fromList ["min", "max", "fst", "snd", "map"]
  = ["min", "max", "fst", "snd", "map"]

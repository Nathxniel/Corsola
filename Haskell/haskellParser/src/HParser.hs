module HParser
  ( parse
  ) where

import HParser.Parse1
import HParser.Parse2
import HParser.Parse3

{-
 - edits haskell parse3 code
 -}
edit
  = foldr (\x acc -> (show x) ++ ('\n':acc)) ""

{-
 - main parsing function
 -}
parse
  = edit . parse3 . parse2 . parse1

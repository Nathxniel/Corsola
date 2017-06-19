module HParser
  ( parse
  ) where

import HParser.Parse1
import HParser.Parse2
import HParser.Parse3

parse :: Parser
parse
  = parse3 . parse2 . parse1

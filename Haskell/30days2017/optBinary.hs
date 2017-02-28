import Control.Monad
import Data.List

main = readLn >>= print . foldr max 0 . map length . filter (\x -> head x == 1) . group . binary

binary 0 = [0]
binary 1 = [1]
binary x = m : binary d
  where
    (d,m) = x `divMod` 2

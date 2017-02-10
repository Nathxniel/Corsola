import Control.Applicative ((<$>))
import Control.Monad 
import qualified Data.Map.Lazy as M
import qualified Data.List as L (nub, group, sort)
import Data.Maybe (fromJust)

main :: IO ()
main = do
  (nub, grp) <- (\s -> (L.nub s, L.group s)) <$> getLine
  x <- readLn :: IO Int
  let vmap = [(l, ord l) | l <- nub]
  let dmap = buildMap . reverse . L.sort . map (\x -> (head x, length x)) $ grp
  qs <- map (search dmap vmap . read) . take x . lines <$> getContents
  putStr . unlines $ qs

buildMap :: [(Char, Int)] -> M.Map Char Int
buildMap []
  = M.empty
buildMap ((c, i) : xs)
  = M.insert c i (buildMap xs)

ord :: Char -> Int
ord x
  = fromEnum x - fromEnum 'a' + 1

search :: M.Map Char Int -> [(Char, Int)] -> Int -> String
search _ [] _
  = "No"
search dmap table@((d,v) : ts) q
  | q `mod` v == 0 = search' d dmap
  | otherwise      = search dmap ts q
  where
    search' d dmap
      | (len * v) >= q = "Yes"
      | otherwise      = search dmap ts q
      where
        len = fromJust (M.lookup d dmap)

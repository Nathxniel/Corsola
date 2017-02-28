import Control.Applicative ((<$>))
import Control.Monad
import qualified Data.Map.Lazy as M
import Data.Maybe

main :: IO ()
main = do
  [size, o] <- map readInt . words <$> getLine
  [qu, qr] <- map readInt . words <$> getLine
  os <- map ((\[x,y] -> (x,y)) . map readInt . words) . take o . lines
          <$> getContents
  let obstacles = interferes size M.empty (qu, qr) os
  let total     = calcMoves size (qu, qr)
  let blocked   = calcBlocked size (qu, qr) obstacles
  print $ total - blocked

data Dir
  = U | D | L | R | UR | UL | BR | BL
  deriving (Eq, Ord, Show)

readInt :: String -> Int
readInt
  = read

calcBlocked 0 _ _
  = 0
calcBlocked 1 _ _
  = 0
calcBlocked _ _ []
  = 0
calcBlocked size (qu, qr) (m:ms)
  = calc m + calcBlocked size (qu, qr) ms
  where
    calc (d, (ou, or))
      | d == R  = right
      | d == L  = or
      | d == U  = up
      | d == D  = ou
      | d == UR = min up right
      | d == UL = min up left
      | d == BR = min down right
      | d == BL = min down left
      where
        right = (size + 1) - or
        up    = (size + 1) - ou
        down  = ou
        left  = or

calcMoves 0 _
  = 0
calcMoves 1 _
  = 0
calcMoves size (u, r)
  = top + bottom + left + right + min top right 
    + min top left + min bottom right + min bottom left
  where
    top    = size - u
    right  = size - r
    left   = size - right - 1
    bottom = size - top - 1 

interferes 0 _ _ _
  = []
interferes 1 _ _ _
  = []
interferes size map _ []
  = M.toList map
interferes size map q@(qu, qr) (o@(ou, or) : os)
  | nInterfere        = interferes size map q os
  | outOfBounds       = interferes size map q os
  | nu == 0 && nr > 0 = insertIf (o <= find R) R
  | nu == 0           = insertIf (o >= find L) L
  | nr == 0 && nu > 0 = insertIf (o <= find U) U
  | nr == 0           = insertIf (o >= find D) D
  | nu >  0 && nr > 0 = insertIf (o <= find UR) UR
  | nu >  0           = insertIf (o <= find UL) UL
  | nr >  0           = insertIf (o >= find BR) BR
  | otherwise         = insertIf (o >= find BL) BL
  where
    insertIf p d
      | p         = interferes size (M.insert d o map) q os
      | otherwise = interferes size map q os
    outOfBounds
      = ou > size || or > size
--  map' d
--    = M.insert d o map
--
-- ~~~~~~~~~~~ i think you wanna be using alter here....
-- M.alter (\a -> smth <$> a) d map
-- a :: Maybe (Int, Int)
    find a
      = fromJust $ M.lookup a (map' a)
    (nu, nr) 
      = (ou - qu, or - qr)
    nInterfere 
      = (ou /= qu) && (or /= qr) && (abs (ou - qu) /= abs (or - qr))

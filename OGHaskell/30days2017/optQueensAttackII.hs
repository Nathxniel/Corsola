import qualified Data.Set as Set
import Data.Ix

solve :: [[Int]] -> Int
solve ([n,k]:[r,c]:rs) = sum . map (move 0 (r,c)) $ [(1,0),(0,1),(-1,0),(0,-1),(1,1),(1,-1),(-1,1),(-1,-1)]
  where
    bs = Set.fromList . map (\[a,b] -> (a,b)) $ rs
    good :: (Int,Int) -> Bool
    good pos = (inRange ((1,1),(n,n)) pos) && (Set.notMember pos bs)
    step (dx,dy) (x,y) = (x+dx,y+dy)
    move n pos dir = let next = step dir pos in if good next then move (n+1) next dir else n

main = getContents >>= print . solve . map (map read . words) . lines

import System.Random
import Data.Function (on)
import Data.List

insertAt :: a -> [a] -> Int -> [a]
insertAt y xs 1     = y : xs
insertAt y (x:xs) n = x : (insertAt y xs (n-1))
insertAt y [] _     = [y]

range :: Enum a => a -> a -> [a]
range
  = enumFromTo

-- takes an infinite list of random numbers
-- and creates a distinct length n list of them
distinctify :: (Eq a) => [a] -> Int -> [a]
distinctify rs n = d rs n []
  where
    d (r:rs) n acc
      | n == 0     = acc
      | elem r acc = d rs n acc
      | otherwise  = d rs (n-1) (r:acc) 
    

-- selects random selection of distinct numbers
rndSelect :: [a] -> Int -> IO [a]
rndSelect xs n  = do
  gen <- getStdGen
  let len = length xs
      is  = randomRs (0, len - 1) gen
      dis = distinctify is n
  newStdGen >> (return (zipWith (!!) (repeat xs) dis))

lotto :: Int -> Int -> IO [Int]
lotto n m
  = rndSelect [1..m] n

rndPermu :: [a] -> IO [a]
rndPermu xs
  = rndSelect xs (length xs)

combinations :: (Ord a) => Int -> [a] -> [[a]]
combinations 0 _  = [[]]
combinations n xs = [y:ys | y:xs' <- tails xs
                          , ys <- combinations (n-1) xs']

disjoint :: (Eq a, Ord a) => [[a]] -> Bool
disjoint [] = False
disjoint xs = foldr (\x acc -> (isDisjoint x) && acc) True cs
  where
    cs               = combinations 2 xs
    isDisjoint [x,y] = (intersect x y) == []

group3 :: (Ord a, Eq a) => [Int] -> [a] -> [[[a]]]
group3 [a,b,c] xs 
  = [[ax,bx,cx] | ax <- combinations a xs
                , bx <- combinations b xs
                , cx <- combinations c xs
                , disjoint [ax,bx,cx]]

lsort :: (Ord a) => [[a]] -> [[a]]
lsort = sortOn length

lfsort :: (Ord a) => [[a]] -> [[a]]
lfsort [[]] = [[]]
lfsort xs   = concat . lsort
            . groupBy ((==) `on` length)
            . lsort $ xs

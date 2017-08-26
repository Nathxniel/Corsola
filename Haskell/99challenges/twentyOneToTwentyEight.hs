import System.Random

insertAt :: a -> [a] -> Int -> [a]
insertAt y xs 1     = y : xs
insertAt y (x:xs) n = x : (insertAt y xs (n-1))
insertAt y [] _     = [y]

range :: Enum a => a -> a -> [a]
range
  = enumFromTo

-- takes an infinite list of random numbers
-- and creates a distinct length n list of them
distinctify :: [Int] -> Int -> [Int]
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
      is = randomRs (0, len - 1) gen
      dis = distinctify is n
  newStdGen >> (return (zipWith (!!) (repeat xs) dis))

lotto :: Int -> Int -> IO [Int]
lotto n m
  = rndSelect [1..m] n

rndPermu :: [a] -> IO [a]
rndPermu xs
  = rndSelect xs (length xs)

--TODO: Problem 26
--  "combinations"
combinations = undefined


data Code a = Single a | Multiple Int a
  deriving (Show, Read, Eq)

encode :: Eq a => [a] -> [Code a]
encode xs
  = enc xs 0

enc :: Eq a => [a] -> Int -> [Code a]
enc [] _
  = []
enc [x] 0
  = [Single x]
enc [x] n
  = [Multiple (n+1) x]
enc (x:y:xs) n
  | x == y    = enc (y:xs) (n+1)
  | n == 0    = (Single x) : enc (y:xs) 0
  | otherwise = (Multiple (n+1) x) : enc (y:xs) 0

decodeModified :: [Code a] -> [a]
decodeModified = concatMap decode
  where
    decode (Single a)     = [a]
    decode (Multiple n a) = replicate n a

dupli :: [a] -> [a]
dupli
  = concatMap (replicate 2)

dropEvery :: [a] -> Int -> [a]
dropEvery xs n
  = [x | (x,i) <- zip xs [1..], mod i n /= 0]

split' :: [a] -> Int -> ([a], [a])
split' [] _ 
  = ([], [])
split' xs 0
  = ([], xs)
split' (x:xs) n
  = (x : left, right)
  where
    (left, right) = split' xs (n-1)

slice :: [a] -> Int -> Int -> [a]
slice xs s e
  = [x | (x,i) <- zip xs [1..], 3 <= i && i <= e]

rotate :: [a] -> Int -> [a]
rotate xs n = right ++ left
  where
    (left, right) = split' xs (mod (n + len) len)
    len = length xs 

removeAt :: Int -> [a] -> (a, [a])
removeAt n xs
  = (xs !! (n-1), [x | (x,i) <- zip xs [1..], i /= n])


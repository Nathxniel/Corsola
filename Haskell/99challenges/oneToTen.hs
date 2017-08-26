import Data.List

myLast :: [a] -> a
myLast
  = last

myButLast :: [a] -> a
myButLast
  = last . init

elementAt :: [a] -> Int -> a
elementAt
  = (!!)

myLength :: [a] -> Int
myLength
  = foldr (\x -> (+ 1)) 0

myReverse :: [a] -> [a]
myReverse
  = foldl (\acc x -> x:acc) []

isPalindrome :: Eq a => [a] -> Bool
isPalindrome xs
  = xs == (reverse xs)

data NestedList a = Elem a | List [NestedList a]

flatten :: NestedList a -> [a]
flatten (Elem e)
  = [e]
flatten (List xs)
  = concatMap flatten xs

compress :: Eq a => [a] -> [a]
compress []
  = []
compress [x]
  = [x]
compress (x:y:xs)
  | x == y    = compress (y:xs)
  | otherwise = x : compress (y:xs)

pack :: Eq a => [a] -> [[a]]
pack []
  = []
pack a@(x:xs)
  = group : pack rest
  where
    (group, rest) = span (==x) a

encode :: Eq a => [a] -> [(Int, a)]
encode
  = (map (\x -> (length x, head x))) . pack

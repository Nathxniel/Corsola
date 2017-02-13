-- Folds - "Everything is a fold!"

sumF :: [Int] -> Int
sumF
  = foldr (+) 0

productF :: [Int] -> Int
productF
  = foldr (*) 1

lengthF :: [a] -> Int
lengthF
  = foldr (\x -> (+) 1) 0

headF :: [a] -> a
headF
  = foldr const (error "fuckoff")

mapF :: (a -> b) -> [a] -> [b] 
mapF
--  = foldr ((:) . f) [] xs
  = flip foldr [] . ((.) (:)) 

foldlF :: (b -> a -> b) -> b -> [a] -> b
foldlF
--  = foldr (flip f) a (reverse xs)
  = ((.) (flip (.) reverse)) . (foldr . flip)

reverseF :: [a] -> [a]
reverseF
  = foldl (flip (:)) []

foldrF :: (a -> b -> b) -> b -> [a] -> b
foldrF
--  = foldl (\acc x -> f x acc) a xs
  = foldl . flip

-- scanl writes foldl in redex order
--  (the order that the statements get evaluated)
--  foldl (+) 0 [1..5] = ((((0 + 1) + 2) + 3) + 4) + 5
--  scanl (+) 0 [1..5] = [0,1,3,6,10,15]

-- scanr writes foldr in redex order starting from the back
--  (so in the literal order the redexes would come on paper)
--  foldr (+) 0 [1..5] = 1 + (2 + (3 + (4 + (5 + 0))))
--  scanr (+) 0 [1..5] = [15,14,12,9,5,0]

-- TODO: right scans in terms of folds

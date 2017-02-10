data SuffixTree = Leaf Int | Node [(String, SuffixTree)] 
                deriving (Eq, Show)

------------------------------------------------------

isPrefix :: String -> String -> Bool
isPrefix x y
  = x == take (length x) y

removePrefix :: String -> String -> String
removePrefix x xs
--Pre: s is a prefix of s'
  = drop (length x) xs

suffixes :: [a] -> [[a]]
suffixes []
 = []
suffixes x
  = x : suffixes (tail x)

isSubstring :: String -> String -> Bool
isSubstring x y 
  = or (map (isPrefix x) (suffixes y))

findSubstrings :: String -> String -> [Int]
findSubstrings x y
  = [pos | (b, pos) <- zippedPositions, b]
  where
    zippedPositions = zip (map (isPrefix x) (suffixes y)) [0..]

------------------------------------------------------

getIndices :: SuffixTree -> [Int]
getIndices (Leaf x)
 = [x] 
getIndices (Node xs)
 = foldr1 (++) [getIndices t | (_, t) <- xs]

partition :: Eq a => [a] -> [a] -> ([a], [a], [a])
partition x' @ (x : xs) y' @ (y : ys)
  | x == y   = (x : xs', ys', zs')
  |otherwise = ([], x', y')
  where 
    (xs', ys', zs') = partition xs ys
partition x' y'
  = ([], x', y')

findSubstrings' :: String -> SuffixTree -> [Int]
findSubstrings' _ (Leaf _)
  = []
findSubstrings' s (Node xs)
  = concat [getIndices t | (a, t) <- xs, isPrefix s a] ++ 
    concat [findSubstrings' (removePrefix a s) t | (a, t) <- xs, isPrefix a s]

------------------------------------------------------

insert :: (String, Int) -> SuffixTree -> SuffixTree
insert (s, n) (tree @ (Node xs))
  | or (map commonPrefix xs) = Node (map inspect xs)
  | otherwise                = Node ((s, Leaf n) : xs)
  where
    inspect :: (String, SuffixTree) -> (String, SuffixTree)
    inspect (a, t)
      | p == "" = (a, t)
      | p == a  = (a, insert (sp, n) t)
      | p /= a  = (p, Node [(sp, Leaf n), (ap, t)])
      where
        (p, sp, ap) = partition s a
    
    commonPrefix :: (String, SuffixTree) -> Bool
    commonPrefix (xs, _)
      =  x /= ""
      where
        (x, _, _) = partition s xs
      

-- This function is given
buildTree :: String -> SuffixTree 
buildTree s
  = foldl (flip insert) (Node []) (zip (suffixes s) [0..length s-1])

------------------------------------------------------
-- Part IV

longestRepeatedSubstring :: SuffixTree -> String
longestRepeatedSubstring (Node xs)
  = s
  where
    (n, s) = (maximum . concatMap (longest (0, []))) xs
  
    longest :: (Int, String) -> (String, SuffixTree) -> [(Int, String)]
    longest (n, xs) (s, (Node lt)) 
      = pair : concatMap (longest pair) lt
      where
        pair = (n + length s, xs ++ s)
    longest xs _ 
      = []

------------------------------------------------------
-- Example strings and suffix trees...

s1 :: String
s1 
  = "banana"

s2 :: String
s2 
  = "mississippi"

t1 :: SuffixTree
t1 
  = Node 
        [("banana", Leaf 0), 
          ("a", Node [("na", Node [("na", Leaf 1), 
                                   ("", Leaf 3)]), 
                     ("", Leaf 5)]), 
          ("na", Node [("na", Leaf 2), 
     ("", Leaf 4)])]

t2 :: SuffixTree
t2 
  = Node [("mississippi", Leaf 0), 
          ("i", Node [("ssi", Node [("ssippi", Leaf 1), 
                                    ("ppi", Leaf 4)]), 
                      ("ppi", Leaf 7), 
                      ("", Leaf 10)]), 
          ("s", Node [("si", Node [("ssippi", Leaf 2), 
                                   ("ppi", Leaf 5)]), 
                      ("i", Node [("ssippi", Leaf 3), 
                                  ("ppi", Leaf 6)])]), 
          ("p", Node [("pi", Leaf 8), 
                      ("i", Leaf 9)])]


import Data.List hiding (insert, partition)

data SuffixTree = Leaf Int | Node [(String, SuffixTree)] 
                deriving (Eq, Show)

------------------------------------------------------

isPrefix :: String -> String -> Bool
isPrefix pre xs
  = isPrefix' $ inits xs
  where
    isPrefix' [x]
      = pre == x
    isPrefix' (x:xs)
      | pre == x  = True
      | otherwise = isPrefix' xs

removePrefix :: String -> String -> String
removePrefix s s'
--Pre: s is a prefix of s'
  = reduce (length s) s'
  where
    reduce 0 xs
      = xs
    reduce n (x:xs)
      = reduce (n-1) xs

suffixes :: [a] -> [[a]]
suffixes
  = init . tails

isSubstring :: String -> String -> Bool
isSubstring pre xs
  = any (isPrefix pre) (suffixes xs)

findSubstrings :: String -> String -> [Int]
findSubstrings pre xs
  = indexes 0 (map (isPrefix pre) (suffixes xs)) []
  where
    indexes _ [] acc
      = acc
    indexes n (x:xs) acc
      | x         = indexes (n+1) xs (n:acc)
      | otherwise = indexes (n+1) xs acc
------------------------------------------------------

getIndices :: SuffixTree -> [Int]
getIndices (Leaf n)
  = [n]
getIndices (Node ts)
  = concatMap (getIndices . snd) ts

partition :: Eq a => [a] -> [a] -> ([a], [a], [a])
partition xs ys
  = (intersect xs ys, xs \\ intersect xs ys, ys \\ intersect xs ys)


partition' [] xs
  = ([], [], xs)
partition' ys []
  = ([], ys, [])
partition' x'@(x:xs) y'@(y:ys)
  | x == y    = (x:a, b, c)
  | otherwise = (a, x', y')
  where
    (a, b, c) = partition' xs ys


findSubstrings' :: String -> SuffixTree -> [Int]
-- "" is a substring of everything
findSubstrings' "" (Leaf n)
  = Leaf n
findSubstrings' _ (Leaf _)
  = []
findSubstrings' (x:xs) (Node ts)
  = smth ts
  where
    smth []
      = []
    smth (((s:_),t):trs)
      | xs == [] && x == s = getIndices t
      | x == s             = findSubstrings' xs t
      | otherwise          = smth trs

------------------------------------------------------

insert :: (String, Int) -> SuffixTree -> SuffixTree
insert
  = undefined
--insert (s, n) (Leaf uh)
--  = Leaf uh
--insert (s, n) (Node stree)
--  = smth stree
--  where
--    smth []
--      = (s, Leaf n) : stree
--    smth ((a,t):ts)
--      | p == []   = smth ts
--      | p == a    = insert (s_p, n) t
--      | otherwise = (p, Node [(s_p, Leaf n), (a_p, t)]) : smth ts
--      where
--        (p, s_p, a_p) = partition s a

-- This function is given
buildTree :: String -> SuffixTree 
buildTree s
  = foldl (flip insert) (Node []) (zip (suffixes s) [0..length s-1])

------------------------------------------------------
-- Part IV

longestRepeatedSubstring :: SuffixTree -> String
longestRepeatedSubstring 
  = undefined

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
  = Node [("banana", Leaf 0), 
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



-- Hackerrank: "Area of a Polygon"

main :: IO ()
main
  = do
      noVerts <- readLn :: IO Int
      verts <- readPairs noVerts
      -- verts is a list of (Int, Int)
      print $ calcArea $ orderVerts verts

squareTest :: [(Int, Int)]
squareTest = [(0, 0), (1, 0), (1, 1), (0,1)]

readPairs :: Int -> IO [(Int, Int)]
readPairs x
  = readPairs' x []
  where
    readPairs' 0 ps
      = return ps
    readPairs' n ps
      = do
          input <- getLine
          readPairs' (n-1) ((pairIze . intIze . words $ input) : ps)
            where
              intIze = foldr (\x acc -> (read x :: Int) : acc) []
              pairIze = (\[x,y] -> (x,y))

calcArea :: [(Int, Int)] -> Double
calcArea vs
  = (fromIntegral second - fromIntegral first) / 2
  where
    first = foldr (\((a,_),(_,b)) acc -> (a * b) + acc) 0 vs'
    second = foldr (\((_,a),(b,_)) acc -> (a * b) + acc) 0 vs'
    vs' = zip vs (tail vs)
    
orderVerts :: [(Int, Int)] -> [(Int, Int)]
-- Pre: there are at least 3 verts
orderVerts s@(v:_)
  = s ++ [v]

-- Algorithm on 6 vertices (pairs)
-- pair 1
-- pair 2
-- pair 3
-- pair 4
-- pair 5
-- pair 6

-- first = foldr (\((a,_),(_,b)) acc -> (a * b) + acc) 0 (the list) 
-- fst pair 1 * snd pair 2
-- fst pair 2 * snd pair 3
-- ... 
-- fst pair 5 * snd pair 6

-- second = foldr (\((_,a),(b,_)) acc -> (a * b) + acc) 0 (the list)
-- snd pair 1 * fst pair 2
-- snd pair 2 * fst pair 3
-- ...
-- snd pair 5 * fst pair 6

-- (second - first) / 2

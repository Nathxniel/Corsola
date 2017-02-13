-- Hackerrank: Perimeter of polygons

main :: IO ()
main
  = do
      noVerts <- readLn :: IO Int
      verts <- readPairs noVerts
      print $ perimeter verts

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

perimeter :: [(Int, Int)] -> Double
-- Pre: there will be at least 3 vertices
perimeter a@(v:y:vs)
  = perimeter' v a
  where
    perimeter' h [x]
      = distance h x
    perimeter' h (f:s:w)
      = distance f s + perimeter' h (s:w)

distance :: (Int, Int) -> (Int, Int) -> Double
distance (a,b) (c,d)
  = sqrt (first + second)
  where
    first = (fromIntegral a - fromIntegral c) ^ 2
    second = (fromIntegral b - fromIntegral d) ^ 2
  

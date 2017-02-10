-- Hackerrank: "Are these functions defined?"

main :: IO ()
main
  -- readNumber of functions
  --  iterate: 
  --  read a number
  --    iterate:
  --      read (number) pairs
  = do
      noFuncs <- readLn :: IO Int
      readFuncs noFuncs

data Answer
  = YES | NO
  deriving Show

readFuncs :: Int -> IO ()
readFuncs 0
  = return ()
readFuncs n
  = do
      noPairs <- readLn :: IO Int
      -- readPairs makes a list of pairs
      pairs <- readPairs noPairs
      print $ convertAnswer $ validate pairs
      readFuncs (n-1)

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

validate :: [(Int, Int)] -> Bool
validate []
  = True
validate all@((a,_):ps)
  = validate' (lookup a ps) (lookup a all)
  where
    validate' Nothing _
      = True && validate ps
    validate' l r
      = (l == r) && validate ps

convertAnswer :: Bool -> Answer
convertAnswer True
  = YES
convertAnswer False
  = NO





-- Tests
posTest :: [(Int, Int)]
posTest = let f = [1..8] in zip f (tail f)

negTest :: [(Int, Int)]
negTest = posTest ++ [(1,1)]

realTest1 :: [(Int, Int)]
realTest1 = [(500,1),(500,2),(500,3),(499,1)]

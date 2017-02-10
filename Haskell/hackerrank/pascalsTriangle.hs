-- Hackerrank: Pascal's Triangle
-- (this is truly a hacked solution but it works)

main :: IO ()
main
  = do
      x <- readLn :: IO Int
      displayPascals x

displayPascals :: Int -> IO ()
displayPascals n
  = displayPascals' n n
  where
    displayPascals' _ 0
      = return ()
    displayPascals' o c
      = do
          putStrLn $ pascal (o-c+1)
          displayPascals' o (c-1)

pascal :: Int -> String
pascal n
  = unwords $ pascal' (n-1) (n-1) []
  where
    pascal' x c acc
      | c < 0     = acc
      | otherwise = pascal' x (c-1) (smth : acc)
      where
        smth = show $ combination x c

combination :: Int -> Int -> Int
combination _ 0
  = 1
combination n r
  = floor $ factn / (factr * factnr)
  where
    factn = fromIntegral $ factorial n
    factr = fromIntegral $ factorial r
    factnr = fromIntegral $ factorial $ n - r

factorial :: Int -> Int
factorial 0
  = 1
factorial n
  = n * factorial (n-1)

main :: IO ()
main
  = do
      s <- getLine
      putStrLn . remBracs $ s

remBracs :: String -> String
remBracs xs
  = remBracs' xs 0
  where
    remBracs' ('(' : xs) 0
      = remBracs' xs 1
    remBracs' ('(' : xs) n
      = '(' : remBracs' xs (n+1)
    remBracs' (')' : xs) 1
      = xs
    remBracs' (')' : xs) n
      = ')' : remBracs' xs (n-1)
    remBracs' (x : xs) n
      = x : remBracs' xs n
    remBracs' [] _
      = []

--store a counter at 0
--get your string
--if you fuck off die

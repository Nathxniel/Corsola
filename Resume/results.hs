import Data.List (genericLength)

main = do
  putStrLn "How many results?"
  results <- readLn :: IO Int
  inputs <- sequence $ replicate results getLine
  print . average . map someFunc $ inputs

someFunc x
  | x == "A*" = 95
  | x == "A+" = 85
  | x == "A"  = 75
  | x == "B"  = 65
  | x == "C"  = 55
  | x == "D"  = 45

average xs
  = (fromIntegral $ sum xs) / genericLength xs

-- Hackerrank: Prefix Compression

main :: IO ()
main
  = do
      str1 <- getLine
      str2 <- getLine
      putStr $ show $ length $ prefix str1 str2
      putStrLn $ ' ' : prefix str1 str2
      putStr $ show $ length str1
      putStrLn $ ' ' : str1
      putStr $ show $ length str2
      putStrLn $ ' ' : str2

prefix :: String -> String -> String
prefix p q
  = prefix' p q []
  where
    prefix' [] _ acc
      = reverse acc
    prefix' _ [] acc
      = reverse acc
    prefix' (p:ps) (q:qs) acc
      | p == q    = prefix' ps qs (q:acc)
      | otherwise = prefix' ps qs acc

-- Hackerrank: Sierpinksi Triangle

main :: IO ()
main
  = do
      iterations <- readLn :: IO Int
      mapIO putStrLn $ sugar $ sierpinksi startTriangle iterations
      where
        sugar
          = (map . map) sugarfication
          where
          -- TODO: change to a case statement
          -- put all your sugarfications here
            sugarfication x
              | x == ' '  = '_'
              | otherwise = x

mapIO :: (a -> IO ()) -> [a] -> IO ()
mapIO f []
  = return ()
mapIO f (x:xs)
  = do
      f x
      mapIO f xs

sierpinksi :: [String] -> Int -> [String]
-- takes a list of strings, returns a list of strings the same size
sierpinksi iter0 n
  = glue (firstHalf) (secondHalf) n
  where
    firstHalf
      = take (div (length iter0) 2) iter0 
    secondHalf
      = drop (div (length iter0) 2) iter0
    glue top bot 0
      = top ++ bot
    glue top _ x
      = (sierpinksi top (x-1)) ++ (calcBottom $ sierpinksi top (x-1))

calcBottom :: [String] -> [String]
calcBottom xs
-- uses SPACE as the default middle of triangle character
-- see function 'sugar' in 'main'
  = dupe (reverse xs) " " []
  where
    dupe [] _ acc
      = acc
    dupe (x:xs) b acc
      = dupe xs (" " ++ b ++ " ") ((pad $ ones ++ b ++ ones) : acc)
      where
        ones = filter (`elem` " 1") x

startTriangle :: [String]
startTriangle
  = create "1" 32 []
  where
    create _ 0 acc
      = acc
    create o n acc
      = create ("1" ++ o ++ "1") (n-1) (acc ++ [pad o])

pad xs
-- 63 is the width of the "canvas" we are using
  | length xs == 63 = xs
  | otherwise       = pad ("_" ++ xs ++ "_")


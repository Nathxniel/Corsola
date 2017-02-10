import Data.List
import Numeric

formatFloatN floatNum numOfDecimals 
  = showFFloat (Just numOfDecimals) floatNum ""

main :: IO ()
main
  = do
      n <- readLn :: IO Int -- junk read
      input <- getLine
      print . mean $ d input
      print . median $ d input
      print . mode $ d input

d :: String -> [Int]
d
  = map (\x -> read x :: Int) . words

mean :: [Int] -> Float
mean []
  = undefined
mean xs
  = realToFrac (sum xs) / genericLength xs

median :: [Int] -> Float
median xs'
  = mean . take 2 $ drop (div (l - d) 2) xs
  where
    xs = sort xs'
    d  = fromEnum $ even l
    l  = length xs

mode :: [Int] -> Int
mode []
  = undefined
mode xs
  = mode' xs []
  where
    mode' [] acc
      = minimum $ [v | (n, v) <- acc, n == (fst . maximum $ acc)]
    mode' (x:xs) acc
      | notElem x as' = mode' xs ((1, x):acc)
      | otherwise     = mode' xs [(n + fromEnum (x==v), v) | (n, v) <- acc]
      where
        as' = map snd acc

test = [(1, 2), (1, 3), (4, 5), (6, 1), (7, 7), (7, 1)]

import Data.Char

main :: IO ()
main = do
  noWords <$> getLine >>= print

noWords :: String -> Int
noWords s
  = nw s True
  where
    nw (x:xs) True
      | isAlpha x = 1 + nw xs False
      | otherwise  = nw xs True
    nw (x:xs) False
      | isAlpha x = nw xs False
      | otherwise  = nw xs True
    nw [] _  = 0

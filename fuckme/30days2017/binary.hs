import Control.Monad

main :: IO ()
main = readLn >>= print . maxOnes . binary

maxOnes :: [Int] -> Int
maxOnes bs
  = maxOnes' bs 0 0
  where
    maxOnes' [] n m
      = max n m
    maxOnes' (l:list) now max
      | l == 1    = maxOnes' list (now + 1) max
      | now > max = maxOnes' list 0 now
      | otherwise = maxOnes' list 0 max

binary :: Int -> [Int]
binary x
  = binary' x []
  where
    binary' 0 acc
      = 0 : acc
    binary' n acc
      = binary' (div n 2) ((mod n 2) : acc) 

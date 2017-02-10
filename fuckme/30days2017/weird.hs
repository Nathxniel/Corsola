-- odd = weird
-- even && v = Not weird
-- even $$ v = weird
-- otherwise = Not weird

-- 5 - 2 = 3
-- 2 - 2 = 0
--so is less than or equal to 3

-- 6 - 6 = 0
-- 20 - 6 =14
-- so is less than or equal to 14

import Control.Applicative
import Control.Monad

main :: IO ()
main
  = do
      x <- readLn :: IO Int
      putStrLn $ weirdCheck x

weirdCheck :: Int -> String
--Pre: 1 <= x <= 100
weirdCheck x
  | odd x           = "Weird"
  | even x && cond1 = "Not Weird"
  | even x && cond2 = "Weird"
  | otherwise       = "Not Weird"
  where
    cond1 = (x - 2) <= 3
    cond2 = (x - 6) <= 14

import Control.Applicative
import Control.Monad

--main :: IO ()
--main
--  = do
--      x <- readLn :: IO Int
--      timesTables x 1 10
--
--timesTables :: Int -> Int -> Int -> IO ()
--timesTables x a n
--  | a > n     = return ()
--  | otherwise = do
--      putStrLn $ show x ++ " x " ++ show a ++ " = " ++ show (x * a)
--      timesTables x (a+1) n

main =
  (readLn :: IO Int) >>= smth

smth x
  = (\x n -> show n ++ "x" ++ show x ++ "=" ++ show (n*x)) <$> (repeat x) <$> [1..10]

--
--(putStrLn over a list that is 
--
--
--list is 1..10
--
--your doing x x 10 = smthx
--           x x 9  = smthy
--           x x 8  = smthz
--
--

import Control.Applicative
import Control.Monad
import Data.List

main :: IO ()
main = do
  x <- readLn :: IO Int
  split x

split :: Int -> IO ()
split 0 = return ()
split n = do
  input <- getLine
  let (a,b) = partition (\(e,i) -> even i) (zip input [0..])
  (\(f,s) -> putStrLn $ f ++ " " ++ s) (map fst a, map fst b)
  split (n-1)

import Control.Monad
import Control.Applicative

main = do
  input <- take 6 . lines <$> getContents
  let array = concatMap (map (read :: String -> Int) . words) $ input
  print . maximum . hourglass $ array

hourglass xss
  = map (\x -> sum $ map (xss !!) (x:[(x-7)..(x-5)] ++ [(x+5)..(x+7)])) (concatMap (\x -> (+x) <$> [7..10]) ((*6) <$> [0..3]))

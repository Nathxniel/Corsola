import Control.Applicative
import Control.Monad
import Data.Maybe
import Data.List

main :: IO ()
main = do
  vs <- concatMap value . group <$> getLine 
  qs <- readLn :: IO Int
  q  <- take qs . lines <$> getContents
  putStr . unlines . map (\q -> yesNo $ elem (read q) vs) $ q

yesNo :: Bool -> String
yesNo b
  | b         = "Yes"
  | otherwise = "No"
  
value xs
  = value' (length xs) (head xs)
  where
    value' 0 _
      = []
    value' n a
      = (fromEnum a - fromEnum 'a' + 1) * n : value' (n - 1) a

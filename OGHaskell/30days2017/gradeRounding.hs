import Control.Monad
import Control.Applicative

main = do
  x <- readLn :: IO Int
  input <- map (calcGrade . read) . take x . lines <$> getContents
  putStr . unlines . map show $ input

calcGrade x
  | x < 38             = x
  | next5 - x < 3      = next5
  | otherwise          = x
  where
    next5 = ceiling (fromIntegral x * 0.2) * 5

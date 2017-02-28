import Control.Monad
import Data.Maybe
import qualified Data.Map.Lazy as Book

main = do
  x <- readLn :: IO Int
  c <- lines <$> getContents
  let tbl = Book.fromList $ map ((\[a,b] -> (a,b)) . words) (take x c)
  forM_ (drop x c) (\line -> putStrLn $ fromMaybe "Not found" ((\number -> line ++ "=" ++ number) <$> Book.lookup line tbl))

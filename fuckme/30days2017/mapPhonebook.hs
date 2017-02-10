import Control.Monad
import qualified Data.Map.Lazy as Book
import Data.Maybe

main = do
  x <- readLn :: IO Int
  book <- buildBook x Book.empty
  forever $ do
    name <- getLine
    putStrLn $ fromMaybe "Not found" (Book.lookup name book
      >>= (\number -> return (name ++ "=" ++ number)))

buildBook 0 book = return book
buildBook x book = do
  [a,b] <- getLine >>= return . words
  buildBook (x - 1) (Book.insert a b book)

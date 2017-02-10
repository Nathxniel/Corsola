import Control.Monad
import Data.Maybe

main = do
  x <- readLn :: IO Int
  tbl <- (sequence $ replicate x getLine) 
    >>= return . map ((\[a,b] -> (a,b)) . words)
  forever $ do
    name <- getLine
    putStrLn $ fromMaybe "Not found" (lookup name tbl
      >>= (\number -> return (name ++ "=" ++ number)))

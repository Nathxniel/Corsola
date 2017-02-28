import Control.Monad
import Control.Applicative

main = putStrLn "press CTRL-c to quit" >> (forever $ do
  unwords . map (\(x:xs) -> x : filter (flip notElem "aeiou") xs) . words <$> getLine >>= putStrLn)
    


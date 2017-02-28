-- Hackerrank: "Hello World n times"

helloWorlds :: Int -> IO ()
helloWorlds x
  = mapIO putStrLn $ take x $ repeat "Hello World"
  where
    mapIO :: (a -> IO ()) -> [a] -> IO ()
    mapIO f []
      = pure ()
    mapIO f (x:xs) 
      = do
          f x
          mapIO f xs

readln :: Read a => String -> IO a 
readln msg
  = putStr msg >> getLine >>= (return . read)

main :: IO ()
main
  = do
      x <- readln "Enter number: " 
      y <- helloWorlds x
      return y


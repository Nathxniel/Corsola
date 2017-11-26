import Control.Parallel
import Control.Monad ( forM_ )
import Control.Concurrent ( forkIO, killThread, threadDelay )

yes :: String -> IO ()
yes s =
  forM_ (replicate 5 s) putStrLn

main :: IO ()
main = do
  h <- forkIO (yes "hello")
  g <- forkIO (yes "goodbye") 
  threadDelay 5000
  killThread h
  killThread g

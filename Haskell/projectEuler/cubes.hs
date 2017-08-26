import Control.Monad
import Control.Applicative

main = do
  putStrLn "Enter grid width"
  width <- readLn :: IO Int
  putStrLn "Enter grid height"
  height <- readLn :: IO Int
  putStrLn "Number of rectangles:"
  print (solve width height)
  verbosesW w h
  verbosesH w h

solve w h
  = sW w h + sH w h

sW 1 h
  = 1
sW w h
  = (w * h) + (sW (w - 1) h)

sH w 1
  = 1
sH w h
  = (w * h) + (sH w (h - 1))

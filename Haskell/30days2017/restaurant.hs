import Control.Applicative
import Control.Monad

main :: IO ()
main
  = do
      cost <- readLn :: IO Float
      tip <- readLn :: IO Float
      tax <- readLn :: IO Float
      putStrLn $ "The total meal cost is " 
                  ++ show (calcCost cost tip tax)
                  ++ " dollars."

calcCost :: (RealFrac a, Integral b) => a -> a -> a -> b
calcCost cost tip tax
  = round $ cost + calc tip + calc tax
  where
    calc x = cost * x / 100
    

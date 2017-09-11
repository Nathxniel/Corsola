import Data.Function (on)
import Control.Monad

infixl 6 `and'`
and' :: Bool -> Bool -> Bool
and'  = (&&)

infixl 4 `or'`
or' :: Bool -> Bool -> Bool
or'   = (||)

infixl 6 `nand'`
nand' :: Bool -> Bool -> Bool
nand' = ((&&) `on` not)

infixl 4 `nor'`
nor' :: Bool -> Bool -> Bool
nor'  = ((||) `on` not)

infixl 5 `xor'`
xor' :: Bool -> Bool -> Bool
xor' a b = (a && (not b)) || (b && (not a))

infixl 3 `impl'`
impl' :: Bool -> Bool -> Bool
impl' a b = (not a) || b

infixl 3 `equ'`
equ' :: Bool -> Bool -> Bool
equ' = (==)

table :: (Bool -> Bool -> Bool) -> IO ()
table f
  = putStrLn . init . unlines 
  $ [p x y | x <- [True, False], y <- [True, False]]
  where
    p x y =  show x ++ " " 
          ++ show y ++ " " 
          ++ show (f x y)

tablen :: Int -> ([Bool] -> Bool) -> IO ()
tablen n f 
  = mapM_ putStrLn [p x ++ (show . f) x | x <- tvs]
  where
    tvs         = replicateM n [True, False]
    p bs        = concatMap (\x -> showb x) bs
    showb False = "False "
    showb True  = "True  "

-- TODO: look at the solution to this properly init
gray :: Int -> [String]
gray 0 = []
gray n = [ | ] ++ [ | ]

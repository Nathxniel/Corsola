-- Monads and Applicatives

import Control.Applicative
import Control.Monad

fZipWith :: Applicative f => (a -> b -> c) -> f a -> f b -> f c
fZipWith
--  = fmap f as <*> bs
  = ((<*>) .) . fmap

--fMap ::  (a -> b) -> [] a -> [] b
--fMap f as
--  =  (<*>) (repeat f) as

sqrtM :: Int -> Maybe Int
sqrtM x
  | x < 0     = Nothing
  | otherwise = Just (floor $ sqrt (fromIntegral x))

sqrtE :: Int -> Either String Int
-- Right is automatically used as the 'correct value'
-- i.e. do notation wont work unless you use this convention
sqrtE x
  | x < 0     = Left (show (root $ abs x) ++ "i") 
  | otherwise = Right (root x)
  where
    root x = floor $ sqrt (fromIntegral x)

halfM :: Int -> Maybe Int
halfM x
  | odd x     = Nothing
  | otherwise = Just (div x 2)

halfE :: Int -> Either String Int
-- Right is automatically used as the 'correct value'
halfE x
  | odd x     = Left (show x ++ " is odd")
  | otherwise = Right (div x 2)

sthM :: Int -> Maybe Int
-- Indentation is of paramount importance for do notation
-- you can't jip do notation into not working
sthM x
  = do
      y <- sqrtM x
      z <- halfM y
      return (z) 

sthE :: Int -> Either String Int
sthE x
  = do
      y <- sqrtE x
      z <- halfE y
      return (z)


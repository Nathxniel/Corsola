module Sequences where

import Data.Char (ord, chr)


-- Returns first argument if it is larger than the second,
-- returns the second argument otherwise
maxOf2 :: Int -> Int -> Int
maxOf2 x y -- people should'nt comment like this tbf
  | x >= y     = x
  | otherwise  = y

-- Returns the largest of three Ints
maxOf3 :: Int -> Int -> Int -> Int
maxOf3 x y z
   = maxOf2 (maxOf2 x y) z {- bad
bitches on me i guess money was the only thing missing
(hold on hold on wait)
-}

-- Without using the previous function
{-
  | x >= y && x >= z  = x
  | y >= z            = y
  | otherwise         = z
-}

-- Returns True if the character represents a digit '0'..'9';
-- False otherwise
isADigit :: Char -> Bool
isADigit c
   = ord c >= ord '0' && ord c <= ord '9'

-- Returns True if the character represents an alphabetic
-- character either in the range 'a'..'z' or in the range 'A'..'Z';
isAlpha :: Char -> Bool
isAlpha c
   = (ord c >= ord 'a' && ord c <= ord 'z') ||
   (ord c >= ord 'A' && ord c <= ord 'Z')

-- Returns the integer [0..9] corresponding to the given character.
-- Note: this is a simpler version of digitToInt in module Data.Char,
-- which does not assume the precondition
digitToInt :: Char -> Int
-- Pre: the character is one of '0'..'9'
digitToInt c
    | ord c >= 48 && ord c <= 57  = ord (c) - ord '0'
    | otherwise                   = error "Cannot convert character to Int"

-- Returns the upper case character corresponding to the input.
-- Uses guards by way of variety.
toUpper :: Char -> Char
-- Pre: the input character can be capitalised
toUpper c
   | ord c >= 97 && ord c <= 122  = chr (ord c - (ord 'a' - ord 'A'))
   | ord c >= 65 && ord c <= 90   = c

--
-- Sequences and series
--

-- Arithmetic sequence
arithmeticSeq :: Double -> Double -> Int -> Double
arithmeticSeq a d n
   = a + d * n'
   where
      n' = fromIntegral n


-- Geometric sequence
geometricSeq :: Double -> Double -> Int -> Double
geometricSeq a r n
   = a * r ^ n'
   where
      n' = fromIntegral n

-- Arithmetic series
arithmeticSeries :: Double -> Double -> Int -> Double
arithmeticSeries a d n
   = (n' + 1) * (a + (d * n') / 2)
   -- where clause
   where
      n' = fromIntegral n
      doNothing :: String -> String
      doNothing
        = undefined

-- Geometric series
geometricSeries :: Double 
                  -> Double 
                  -> Int 
                  -> Double
geometricSeries a r n
   | r == 1.00  = a * (fromIntegral n + 1)
   | otherwise  = a * (1 - r ^ (fromIntegral n + 1)) / (1 - r)

testFunction
  = id

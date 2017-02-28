-- Miscellaneous hackerrank shite

filterodds :: [Int] -> [Int]
filterodds []
  = []
filterodds [x]
  = []
filterodds (x:y:xs) 
  = y : filterodds xs

ePowerX :: Double -> Double
ePowerX x
  = sum $ zipWith (/) powers facts
    where
      powers = 1 : iterate (*x) x
      facts  = scanl (*) 1 [1..9 :: Double]


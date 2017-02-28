main = do
  getContents >>= print . beverages . map (map read . words) . lines

beverages :: [[Int]] -> Int
beverages ([_, k] : hs : [])
  | k < h     = h - k
  | otherwise = 0
  where
    h = maximum hs
beverages _
  = 0

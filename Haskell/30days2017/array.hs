import Control.Monad

--main = do
--  [_,x] <- sequence [getLine, getLine]
--  putStrLn . unwords . reverse . words $ x

main = getLine >> getLine >>= (putStrLn . unwords . reverse . words)

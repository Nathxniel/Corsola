import Control.Monad
import Control.Applicative

main :: IO ()
main = do
  ls <- lines <$> getContents
  putStrLn . head .  parse  $ ls

parse :: [String] -> [String]
-- parsing single-line comments
parse ('-':'-':s):ss
  = parse ss
parse ('{':'-':s):ss
  = comment ss
parse ss
  = id ss

comment :: [String] -> [String]
comment (_:'-':"}"):ss
  = parse ss
comment (_):ss
  = comment ss

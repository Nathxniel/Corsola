import System.IO
import System.Environment (getArgs)
import Control.Monad
import Control.Applicative
type Parser = [String] -> [String]

main = do
[readfile, writefile] <- getArgs
ls <- map (unwords . words) . lines <$> readFile readfile
writeFile writefile (unlines . parse $ ls)

parse (('-':'-':_):ss)
= parse ss
parse (('{':'-':_):ss)
= comment ss
parse ("":ss)
= parse ss
parse a@((' ':_):_)
= space a
parse (s:ss)
= funcdef s : parse ss
parse []
= []

comment (("-}"):ss)
= parse ss
comment ((x:xs):ss)
= comment (xs:ss)
comment ([]:ss)
= comment ss

space ((' ':s):ss)
= parse (s:ss)

funcdef xs
| isFuncDef xs = []
| otherwise = xs
where

isFuncDef (':':':':_)
= True
isFuncDef (x:xs)
= isFuncDef xs
isFuncDef []
= False

import System.IO (readFile, writeFile)
import System.Environment (getArgs)
import Control.Monad
import Control.Applicative 
import Data.Char
import Data.List
import qualified Data.Set as S

type Parser    = [String] -> [String]
type Block     = [Statement]
data Statement = Fstat (String, String)
               | FuncDef String         
               | SLineC String          
               | MLineC String          
               | MdleStat String        
               | ImprtStat String       
               | Pattern (Block, Block) 
               deriving (Show)

-- function statements (lhs, rhs)
-- function definitions
-- single line comments
-- multiline comments
-- module statements
-- import statements
-- pattern: (body, where clause)

-- File IO version main
--main :: IO ()
--main = do
--  [readfile, writefile] <- getArgs
--  ls <- map (unwords . words) . lines <$> readFile readfile
--  writeFile writefile (unlines . parse $ ls)

-- Terminal version main
main :: IO ()
main = do
  ls <- lines <$> getContents
  putStrLn . unlines . parse $ ls

intersperseMap :: String -> (String -> [String]) -> Parser
intersperseMap d f
  = foldr (\x acc -> (words x) ++ (d:acc)) []

parse :: Parser
parse ls
  = parse2 . parse1 . (intersperseMap "\n" words) $ ls

parse2 = undefined

parse1 :: [String] -> Block
parse1 [] = []

parse1 ("\n":tks)
  = parse1 tks
parse1 ("-}":tks)
  = parse1 tks

parse1 (('-':'-':tk):tks)
  = slinec : parse1 rest
  where
    (slinec, rest)
      = parseSLineC (tk:tks)
parse1 (('{':'-':tk):tks)
  = mlinec : parse1 rest
  where
    (mlinec, rest)
      = parseMLineC (tk:tks)
parse1 ("import":tks)
  = imprtstat : parse1 rest
  where
    (imprtstat, rest)
      = parseImprtStat tks
parse1 ("module":tks)
  = mdlestat : parse1 rest
  where
    (mdlestat, rest)
      = parseMdleStat tks
parse1 (tk:tks)
  = funcstat : parse1 rest
  where
    (funcstat, rest)
      = parseFunc (tk:tks)

parseSLineC :: [String] -> (Statement, [String])
parseSLineC tks
  = (SLineC (unwords $ sline), rest)
  where
    (sline, rest) = break (=="\n") tks 

parseMLineC :: [String] -> (Statement, [String])
parseMLineC tks
  = (MLineC (unwords mline), rest)
  where
    (mline, rest) = break (=="-}") tks 

parseImprtStat = undefined

parseMdleStat = undefined

parseFunc :: [String] -> (Statement, [String])
parseFunc tks
  = pf tks [] []
  where
    pf (tk:tks) [] []
      = undefined

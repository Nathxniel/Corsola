import System.IO (readFile, writeFile)
import System.Environment (getArgs)
import Control.Monad
import Control.Applicative 
import Data.Char
import Data.List
import qualified Data.Set as S

type Parser    = [String] -> [String]
type Block     = [Statement]
data Statement = Fstat (String, String) -- function (lhs, rhs)
               | FLine String           -- line within a function
               | FuncDef String         -- function definitions
               | SLineC String          -- single line comments
               | MLineC String          -- multiline comments
               | MdleStat String        -- module statements
               | ImprtStat String       -- import statements
               | Pattern (Block, Block) -- (body, where clause)  
               deriving (Show)

-- File IO version main
main :: IO ()
main = do
  [readfile, writefile] <- getArgs
  ls <- lines <$> readFile readfile
  (writeFile writefile) . show . parse2 . parse1 $ ls 

{- Utility function:
 -
 - Maps a function over a list adding an element inbetween
 -}
intersperseMap :: String -> (String -> [String]) -> Parser
intersperseMap d f
  = foldr (\x acc -> (f x) ++ (d:acc)) []

{- The Parser
 -
 - Converts lines into readable format
 - Identifies comments and functions
 - Converts
 -}
parse :: Parser
parse ls
  = parse3 . parse2 . parse1 $ ls

{- Converts lines into readable format
 -
 -
 -}
parse1 :: Parser
parse1 
  = intersperseMap "\n" words

{- Identifies:
 -
 - Comments
 - Function lines
 - Module and import statements
 -}
parse2 :: [String] -> Block
parse2 tks = 
  case tks of
    []            -> []
    ("\n"):r      -> parse2 r
    ("-}"):r      -> parse2 r
    ('-':'-':t):r -> (fst $ parseSLineC (t:r)) : (parse2.snd.parseSLineC $ (t:r))
    ('{':'-':t):r -> (fst $ parseMLineC (t:r)) : (parse2.snd.parseMLineC $ (t:r))
    ("import"):r  -> (fst $ parseImprtStat r)  : (parse2.snd.parseImprtStat $ r)
    ("module"):r  -> (fst $ parseMdleStat r)   : (parse2.snd.parseMdleStat $ r)
    (t:r)         -> (fst $ parseFunc (t:r))   : (parse2.snd.parseFunc $ (t:r))

parse3 = undefined

parseSLineC :: [String] -> (Statement, [String])
parseSLineC tks
  = (SLineC (unwords sline), rest)
  where
    (sline, rest) = break (=="\n") tks 

parseMLineC :: [String] -> (Statement, [String])
parseMLineC tks
  = (MLineC (unwords mline), rest)
  where
    (mline, rest) = break (=="-}") tks 

-- helper :/
parseMultiline :: [String] -> [String] 
                   -> (String -> Statement) -> (Statement, [String])
parseMultiline tks acc typ =
  case tks of
    []            -> (typ (unwords acc), [])
    ('-':'-':_):_ -> (typ (unwords acc), tks)
    ('{':'-':_):_ -> (typ (unwords acc), tks)
    ("import"):_  -> (typ (unwords acc), tks)
    ("module"):_  -> (typ (unwords acc), tks)
    (t:ts)        -> parseMultiline ts (acc ++ [t]) typ

parseImprtStat :: [String] -> (Statement, [String])
parseImprtStat tks
  = parseMultiline tks [] ImprtStat

parseMdleStat :: [String] -> (Statement, [String])
parseMdleStat tks
  = parseMultiline tks [] MdleStat

parseFunc :: [String] -> (Statement, [String])
parseFunc tks
  = parseMultiline tks [] FLine

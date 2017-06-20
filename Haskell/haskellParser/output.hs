ImprtStat "System.IO (readFile, writeFile) \n"
ImprtStat "System.Environment (getArgs) \n"
ImprtStat "Control.Monad \n"
ImprtStat "Control.Applicative \n"
ImprtStat "Data.Char \n \n"
TypeStat "Parser = [String] -> [String] \n \n"
SLineC " File IO version main"
Func ([Fstat ("main :: IO () main","= do")],[])
SLineC " get read and write location from program arguments"
Func ([Fstat ("[readfile, writefile] <- getArgs","")],[])
SLineC " remove extraneous spaces"
Func ([Fstat ("ls <- map (unwords . words) . lines <$> readFile readfile","")],[])
SLineC " write output to file"
Func ([Fstat ("writeFile writefile (unlines . parse $ ls)","")],[])
SLineC " Terminal version main"
SLineC "main :: IO ()"
SLineC "main = do"
SLineC " ls <- lines <$> getContents"
SLineC " putStrLn . unlines . parse $ ls"
MLineC " the parser"
Func ([Fstat ("parse :: Parser","")],[])
SLineC " parsing single-line comments"
Func ([Fstat ("parse (('-':'-':s):ss)","= ('-':'-':' ':s) : parse ss parse (('{':'-':s):ss) = comment (s:ss)")],[])
SLineC "empty lines and spaces"
Func ([Fstat ("parse (\"\":ss)","= parse ss parse a@((' ':_):_) = space a")],[])
SLineC "function definitions"
Func ([Fstat ("parse (s:ss) | isFuncDef s","= s : processFunction ss | otherwise = parse ss parse [] = []")],[])
SLineC " helper functions for specific parses"
SLineC " strip spaces"
Func ([Fstat ("strip :: String -> String strip []","= [] strip (' ':cs) = strip cs strip (c:cs) = c : strip cs")],[])
SLineC " multi-line comments"
Func ([Fstat ("comment :: Parser comment ([]:ss)","= comment ss comment ((\"-}\"):ss) = parse ss comment (('-':'}':s):ss) = ('-':'-':' ':s) : parse ss comment (s:ss) | ended = rest : parse (after:ss) | otherwise = ('-':'-':' ':s) : comment ss where isCommentEnd ('-':'}':xs) before = (True, ('-':'-':' ':(reverse before)), xs) isCommentEnd (x:xs) before = (e || False, b, a) where (e, b, a) = isCommentEnd xs (x:before) isCommentEnd [] before = (False, before, []) (ended, rest, after) = isCommentEnd s []")],[])
SLineC " comment ((x:xs):ss)"
SLineC " = comment (xs:ss)"
SLineC " comment ([]:ss)"
SLineC " = comment ss"
SLineC " empty space"
Func ([Fstat ("space :: Parser space ((' ':s):ss)","= parse (s:ss) processFunction :: Parser processFunction ss = pfunc ss [] pfunc [] _ = [] pfunc ([]:[]:prgm) function = pfunc prgm function pfunc (('-':'-':s):ss) function = ('-':'-':' ':s) : pfunc ss function pfunc (('{':'-':s):ss) _ = comment (s:ss) pfunc [p] function = (processWhere (reverse function)) ++ (parse [p]) pfunc (p:q:prgm) function | isFuncDef q = (processWhere (reverse (p:function))) ++ (parse prgm) | otherwise = pfunc prgm (q:p:function) processWhere (\"\":func) = processWhere func processWhere func | hasWhere func = pwhere func [] | otherwise = func hasWhere [] = False hasWhere (f:func) | strip f == \"where\" = True | otherwise = hasWhere func pwhere func [] = \"YO\":func")],[])
SLineC " pwhere (f:func) fn"
SLineC " | strip f == \"where\" = mend (reverse fn) (makeWhereMap func)"
SLineC " | otherwise = pwhere func (f:fn)"
SLineC "mend function wheremap"
SLineC " = concatMap (\\f -> concat . (replace wheremap) $ (words f)) function"
SLineC " where"
SLineC " replace wheremap tokens"
SLineC " function definitions"
Func ([Fstat ("isFuncDef :: String -> Bool isFuncDef (':':':':_)","= True isFuncDef (x:xs) = isFuncDef xs isFuncDef [] = False")],[])

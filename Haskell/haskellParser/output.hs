MdleStat "Sequences where \n \n"
ImprtStat "Data.Char (ord, chr) \n \n \n"
SLineC " Returns first argument if it is larger than the second,"
SLineC " returns the second argument otherwise"
FuncDef "maxOf2::Int->Int->Int"
Pattern (FStat (["maxOf2","x","y","\n"],[]),[])
SLineC " people should'nt comment like this tbf"
Pattern (FStat (["|","x",">=","y"],["=","x"]),[])
Pattern (FStat (["|","otherwise"],["=","y","\n","\n"]),[])
SLineC " Returns the largest of three Ints"
FuncDef "maxOf3::Int->Int->Int->Int"
Pattern (FStat (["maxOf3","x","y","z","\n"],["=","maxOf2","(maxOf2","x","y)","z","\n"]),[])
MLineC " bad \n bitches on me i guess money was the only thing missing \n (hold on hold on wait) \n"
SLineC " Without using the previous function"
MLineC " \n | x >= y && x >= z = x \n | y >= z = y \n | otherwise = z \n"
SLineC " Returns True if the character represents a digit '0'..'9';"
SLineC " False otherwise"
FuncDef "isADigit::Char->Bool"
Pattern (FStat (["isADigit","c","\n"],["=","ord","c",">=","ord","'0'","&&","ord","c","<=","ord","'9'","\n","\n"]),[])
SLineC " Returns True if the character represents an alphabetic"
SLineC " character either in the range 'a'..'z' or in the range 'A'..'Z';"
FuncDef "isAlpha::Char->Bool"
Pattern (FStat (["isAlpha","c","\n"],["=","(ord","c",">=","ord","'a'","&&","ord","c","<=","ord","'z')","||","\n","(ord","c",">=","ord","'A'","&&","ord","c","<=","ord","'Z')","\n","\n"]),[])
SLineC " Returns the integer [0..9] corresponding to the given character."
SLineC " Note: this is a simpler version of digitToInt in module Data.Char,"
SLineC " which does not assume the precondition"
FuncDef "digitToInt::Char->Int\n"
SLineC " Pre: the character is one of '0'..'9'"
Pattern (FStat (["digitToInt","c","\n","|","ord","c",">=","48","&&","ord","c","<=","57"],["=","ord","(c)","-","ord","'0'","\n","|","otherwise","=","error","\"Cannot","convert","character","to","Int\"","\n","\n"]),[])
SLineC " Returns the upper case character corresponding to the input."
SLineC " Uses guards by way of variety."
FuncDef "toUpper::Char->Char\n"
SLineC " Pre: the input character can be capitalised"
Pattern (FStat (["toUpper","c","\n","|","ord","c",">=","97","&&","ord","c","<=","122"],["=","chr","(ord","c","-","(ord","'a'","-","ord","'A'))","\n","|","ord","c",">=","65","&&","ord","c","<=","90","=","c","\n","\n"]),[])
SLineC ""
SLineC " Sequences and series"
SLineC ""
SLineC " Arithmetic sequence"
FuncDef "arithmeticSeq::Double->Double->Int->Double"
Pattern (FStat (["arithmeticSeq","a","d","n","\n"],["=","a","+","d","*","n'","\n"]),[FLine "where \n n' = fromIntegral n \n \n \n"])
SLineC " Geometric sequence"
FuncDef "geometricSeq::Double->Double->Int->Double"
Pattern (FStat (["geometricSeq","a","r","n","\n"],["=","a","*","r","^","n'","\n"]),[FLine "where \n n' = fromIntegral n \n \n"])
SLineC " Arithmetic series"
FuncDef "arithmeticSeries::Double->Double->Int->Double"
Pattern (FStat (["arithmeticSeries","a","d","n","\n"],["=","(n'","+","1)","*","(a","+","(d","*","n')","/","2)","\n"]),[FLine "where \n n' = fromIntegral n \n \n"])
SLineC " Geometric series"
FuncDef "geometricSeries::Double->Double->Int->Double"
Pattern (FStat (["geometricSeries","a","r","n","\n","|","r","==","1.00"],["=","a","*","(fromIntegral","n","+","1)","\n","|","otherwise","=","a","*","(1","-","r","^","(fromIntegral","n","+","1))","/","(1","-","r)","\n","\n","testFunction","\n","=","id","\n"]),[])

import Control.Monad

data Tree a = Empty | Branch a (Tree a) (Tree a)
  deriving (Show, Eq)

leaf :: a -> Tree a
leaf x = Branch x Empty Empty

showTree :: (Show a) => Tree a -> String
showTree Empty = ""
showTree (Branch x tl tr)
  = show x ++ "\n" ++ showTree tl ++ showTree tr



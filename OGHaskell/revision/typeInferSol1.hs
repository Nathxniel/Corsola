import Data.Maybe

data Expr = Number Int |
            Boolean Bool |
            Id String  |
            Prim String |
            Cond Expr Expr Expr |
            App Expr Expr |
            Fun String Expr
          deriving (Eq, Show)

data Type = TInt |
            TBool |
            TFun Type Type |
            TVar String |
            TErr 
          deriving (Eq, Show)

showT :: Type -> String
showT TInt  
  = "Int"
showT TBool 
  = "Bool"
showT (TFun t t') 
  = "(" ++ showT t ++ " -> " ++ showT t' ++ ")"
showT (TVar a) 
  = a
showT TErr  
  = "Type error"

type TypeTable = [(String, Type)]

type TEnv 
  = TypeTable    -- i.e. [(String, Type)]

type Sub 
  = TypeTable    -- i.e. [(String, Type)]  

-- Built-in function types...
primTypes :: TypeTable
primTypes 
  = [("+", TFun TInt (TFun TInt TInt)),
     (">", TFun TInt (TFun TInt TBool)),
     ("==", TFun TInt (TFun TInt TBool)),
     ("not", TFun TBool TBool)]

------------------------------------------------------
-- PART I

-- Pre: The search item is in the table
lookUp :: Eq a => a -> [(a, b)] -> b
lookUp key table
  = fromJust (lookup key table)

tryToLookUp :: Eq a => a -> b -> [(a, b)] -> b
tryToLookUp key def table
  = fromMaybe def (lookup key table)

-- Pre: The given value is in the table
reverseLookUp :: Eq b => b -> [(a, b)] -> [a]
reverseLookUp value table 
  = [k | (k, v) <- table, v == value] 

occurs :: String -> Type -> Bool
occurs s (TVar s')   = s == s'
occurs s (TFun t t') = (occurs s t) || (occurs s t')
occurs _ _ = False

------------------------------------------------------
-- PART II

-- Pre: There are no user-defined functions (constructor Fun)
-- Pre: All type variables in the expression have a binding in the given 
--      type environment
inferType :: Expr -> TEnv -> Type
inferType (Number _) _    = TInt
inferType (Boolean _) _   = TBool
inferType (Id x) env      = lookUp x env
inferType (Prim x) _      = lookUp x primTypes
inferType (Cond e1 e2 e3) env
  | inferType e1 env /= TBool = TErr
  | inferType e2 env /= inferType e3 env = TErr
  | otherwise = inferType e2 env
inferType (App e1 e2) env = inferApp (inferType e1 env) (inferType e2 env) env
  where
    inferApp (TFun t t') t'' env
      | t == t''   = t'
      | otherwise  = TErr 
    inferApp _ _ _ = TErr

------------------------------------------------------
-- PART III

applySub :: Sub -> Type -> Type
applySub sub t@(TVar x) 
  = tryToLookUp x t sub
applySub sub (TFun t t')
  = TFun (applySub sub t) (applySub sub t')
applySub sub t = t

unify :: Type -> Type -> Maybe Sub
unify t t'
  = unifyPairs [(t, t')] []

unifyPairs :: [(Type, Type)] -> Sub -> Maybe Sub
unifyPairs ((TInt, TInt):ps) sub 
  = unifyPairs ps sub
unifyPairs ((TBool, TBool):ps) sub 
  = unifyPairs ps sub
unifyPairs ((TVar v, TVar v'):ps) sub
  | v == v' = unifyPairs ps sub
  | otherwise = Nothing
unifyPairs ((TVar v, t):ps) sub
  | occurs v t = Nothing
  | otherwise  = unifyPairs (map (\(p,p') -> (appSub p, appSub p')) ps) ((v, t):sub)
  where 
    appSub = applySub [(v, t)]
unifyPairs ((t, t'@(TVar v)):ps) sub
  = unifyPairs ((t', t):ps) sub
unifyPairs ((TFun t1 t2, TFun t1' t2'):ps) sub
  = unifyPairs ((t1, t1'):(t2, t2'):ps) sub
unifyPairs [] s = Just s
unifyPairs _ _  = Nothing

------------------------------------------------------
-- PART IV

updateTEnv :: TEnv -> Sub -> TEnv
updateTEnv tenv tsub
  = map modify tenv
  where
    modify (v, t) = (v, applySub tsub t)

combine :: Sub -> Sub -> Sub
combine sNew sOld
  = sNew ++ updateTEnv sOld sNew

-- In combineSubs [s1, s2,..., sn], s1 should be the *most recent* substitution
-- and will be applied *last*
combineSubs :: [Sub] -> Sub
combineSubs 
  = foldr1 combine

inferPolyType :: Expr -> Type
inferPolyType exp
  = resType
  where 
    (_, resType, _) = inferPolyType' exp [] infNList 
    infNList        = [concat ["a", show n] | n <- [1..]]

-- You may optionally wish to use one of the following helper function declarations
-- as suggested in the specification. 

inferPolyType' :: Expr -> TEnv -> [String] -> (Sub, Type, [String])
inferPolyType' (Number _) _ s
  = ([], TInt, s)
inferPolyType' (Boolean _) _ s
  = ([], TBool, s)
inferPolyType' (Id x) env s
  = ([], lookUp x env, s)
inferPolyType' (Prim x) env s
  = ([], lookUp x primTypes, s)
inferPolyType' (Fun x e) env (s:ss)
  = (sub, res, ss')
  where
    (sub, te, ss')  = inferPolyType' e ((x, TVar s):env) ss
    sth = applySub sub (TVar s) 
    res = if te == TErr then TErr else TFun sth te
inferPolyType' (App f e) env (s:ss)
  | isJust resSub 
    = ((combineSubs [fromJust resSub, sub', sub]), applySub (fromJust resSub) (TVar s), ss'')
  | otherwise = ([], TErr, [])
  where
    (sub, tf, ss') = inferPolyType' f env ss
    (sub', te, ss'') = inferPolyType' e (updateTEnv env sub) ss'
    resSub = unify tf (TFun te (TVar s)) 

--TODO: Cond

------------------------------------------------------
-- Monomorphic type inference test cases from Table 1...

env :: TEnv
env = [("x",TInt),("y",TInt),("b",TBool),("c",TBool)]

ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8 :: Expr
type1, type2, type3, type4, type5, type6, type7, type8 :: Type

ex1 = Number 9
type1 = TInt

ex2 = Boolean False
type2 = TBool

ex3 = Prim "not"
type3 =  TFun TBool TBool

ex4 = App (Prim "not") (Boolean True)
type4 = TBool

ex5 = App (Prim ">") (Number 0)
type5 = TFun TInt TBool

ex6 = App (App (Prim "+") (Boolean True)) (Number 5)
type6 = TErr

ex7 = Cond (Boolean True) (Boolean False) (Id "c")
type7 = TBool

ex8 = Cond (App (Prim "==") (Number 4)) (Id "b") (Id "c")
type8 = TErr

------------------------------------------------------
-- Unification test cases from Table 2...

u1a, u1b, u2a, u2b, u3a, u3b, u4a, u4b, u5a, u5b, u6a, u6b :: Type
sub1, sub2, sub3, sub4, sub5, sub6 :: Maybe Sub

u1a = TFun (TVar "a") TInt
u1b = TVar "b"
sub1 = Just [("b",TFun (TVar "a") TInt)]

u2a = TFun TBool TBool
u2b = TFun TBool TBool
sub2 = Just []

u3a = TFun (TVar "a") TInt
u3b = TFun TBool TInt
sub3 = Just [("a",TBool)]

u4a = TBool
u4b = TFun TInt TBool
sub4 = Nothing

u5a = TFun (TVar "a") TInt
u5b = TFun TBool (TVar "b")
sub5 = Just [("b",TInt),("a",TBool)]

u6a = TFun (TVar "a") (TVar "a")
u6b = TVar "a"
sub6 = Nothing

------------------------------------------------------
-- Polymorphic type inference test cases from Table 3...

ex9, ex10, ex11, ex12, ex13, ex14 :: Expr
type9, type10, type11, type12, type13, type14 :: Type

ex9 = Fun "x" (Boolean True)
type9 = TFun (TVar "a1") TBool

ex10 = Fun "x" (Id "x")
type10 = TFun (TVar "a1") (TVar "a1")

ex11 = Fun "x" (App (Prim "not") (Id "x"))
type11 = TFun TBool TBool

ex12 = Fun "x" (Fun "y" (App (Id "y") (Id "x")))
type12 = TFun (TVar "a1") (TFun (TFun (TVar "a1") (TVar "a3")) (TVar "a3"))

ex13 = Fun "x" (Fun "y" (App (App (Id "y") (Id "x")) (Number 7)))
type13 = TFun (TVar "a1") (TFun (TFun (TVar "a1") (TFun TInt (TVar "a3"))) 
              (TVar "a3"))

ex14 = Fun "x" (Fun "y" (App (Id "x") (Prim "+"))) 
type14 = TFun (TFun (TFun TInt (TFun TInt TInt)) (TVar "a3")) 
              (TFun (TVar "a2") (TVar "a3"))


{-# LANGUAGE FlexibleInstances #-}

module Typeclasses where

import Control.Applicative

--  A good-old binary tree data structure.
data Tree a
  = Empty
  | Node (Tree a) a (Tree a)
  deriving (Eq, Ord, Show)

--  Some ways of holding marks. Lists are great, but (ordered) binary trees can
--  often provide better complexity (logarithmic rather than linear) for common
--  operations. Choices, choices...

type StudentMark
  = (String, Int)

firstYearL :: [StudentMark]
firstYearL
  = [("Will", 10), ("Tristan", 1), ("Bob", 3)]

--  Note that this tree is ordered -- if you flatten it *in-order*, you get a
--  sorted list.
firstYearT :: Tree StudentMark
firstYearT
  = Node (Node Empty ("Bob", 3) Empty) ("Tristan", 1) (Node Empty ("Will", 10) Empty)

--  Some marking functions and an implementation of CATE backed by lists. It's a
--  nice demonstration of why map is so useful, but it only works on lists.

tony, phdMarker :: StudentMark -> StudentMark

tony (_, m)
  = ("Bob", m - 10000)

phdMarker (n, m)
  = (n ++ "!", m + 1)

gradeStudentsL :: [StudentMark] -> [StudentMark]
gradeStudentsL
  = map (tony . phdMarker)

--  If we want to use trees to hold our marks, we need a new mapping function.
--  That's what mapT is.
mapT :: (a -> b) -> Tree a -> Tree b
mapT f Empty
  = Empty

mapT f (Node l x r)
  = Node (mapT f l) (f x) (mapT f r)

--  Now we can map over trees.
gradeStudentsT :: Tree StudentMark -> Tree StudentMark
gradeStudentsT
  = mapT (tony . phdMarker)

--  What about Maybe? That's an interesting way of holding data too -- it's
--  just like a list, except that there can be at most a single value.

firstYearM :: Maybe StudentMark
firstYearM
  = Just ("Tristan", 1)

mapMaybe :: (a -> b) -> Maybe a -> Maybe b
mapMaybe f Nothing
  = Nothing

mapMaybe f (Just x)
  = Just (f x)

--  This is tedious. We've now got three different mapping functions, all with
--  basically identical types:
--
--  map       :: (a -> b) -> [a]      -> [b]
--  mapT      :: (a -> b) -> Tree a   -> Tree b
--  mapMaybe  :: (a -> b) -> Maybe a  -> Maybe b
--
--  The only difference is the type that wraps the as and bs. We've seen before
--  how functions are actually curried, i.e. (+) is the function that takes a
--  single value and returns *another* function that takes a value and adds 4
--  to it. Well, the same is effectively true of types!
--
--  *Pause for effect*
--
--  What this means is, Tree is a type function -- it takes a type like Int
--  and gives you a new type (Tree Int). Maybe is the same -- it takes a type
--  and gives you a type. With this knowledge, we can abstract over type
--  functions! This is precisely what the functor class does:
--
--  class Functor f where
--    fmap :: (a -> b) -> f a -> f b
--
--  The Prelude defines instances for [] and Maybe, so we'll write one for Tree
--  here:

instance Functor Tree where
  fmap = mapT

--  What does this buy us? We still had to write fmap for Trees. Well, the
--  point is this: if we only *use* fmap in our calling code (i.e., the bit
--  that doesn't care whether we've used trees or lists), then that code can
--  stay the same when we change our implementation! All we need to do is write
--  an appropriate functor instance. For example, below is a version of
--  gradeStudents that works on *any* functor.

gradeStudentsF :: Functor f => f StudentMark -> f StudentMark
gradeStudentsF
  = fmap (tony . phdMarker)

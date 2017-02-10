module Monads where

import Control.Applicative
import Control.Monad

--  We'll start with this lovely bunch of functions. They all have strict
--  preconditions, encoded using the 'error' function.
--
--  [1] Which is good, because they can be composed easily, as in 'f', or some
--      expression like "squareRoot . half".
--
--  [2] Which is *really* bad, because we were taught never to talk to 'error'
--      (or strangers).
--
--  SELECT OPTION: _

squareRoot :: Int -> Int
squareRoot x
  | x < 0     = error "squareRoot: negative number passed"
  | otherwise = floor (sqrt (fromIntegral x))

half :: Int -> Int
half x
  | odd x     = error "half: odd number passed"
  | otherwise = x `div` 2

divide :: Int -> Int -> Int
divide x y
  | y == 0    = error "divide: divisor is zero"
  | otherwise = x `div` y

f :: Int -> Int
f x
  = c
    where
      a = squareRoot x
      b = half a
      c = divide a b

--  You're here because you selected option 2. Haskell is a rich language --
--  there must be a better way of encoding the possibility of failure, right?
--  For example, this sounds like the perfect job for 'Maybe':
--
--  data Maybe a
--    = Nothing
--    | Just a
--
--  When a function returns a value of type 'Maybe a', it's either going to
--  succeed (and return 'Just' an 'a'), or fail (and return 'Nothing'). That's
--  much nicer than 'error':

squareRootM :: Int -> Maybe Int
squareRootM x
  | x < 0     = Nothing
  | otherwise = Just (floor (sqrt (fromIntegral x)))

halfM :: Int -> Maybe Int
halfM x
  | odd x     = Nothing
  | otherwise = Just (x `div` 2)

divideM :: Int -> Int -> Maybe Int
divideM x y
  | y == 0    = Nothing
  | otherwise = Just (x `div` y)

--  But it's not all good news -- we completely ignored point [1], remember.
--  Compositionality is gone! We can't write "squareRootM . halfM"
--  ('squareRootM' expects an 'Int' whilst 'halfM' returns a 'Maybe Int') and
--  the rewrite of 'f' is a helper function nightmare:

fMaybe :: Int -> Maybe Int
fMaybe x
  = mc
    where
      ma  = squareRootM x
      mb  = halfMHelper mb
      mc  = divideMHelper ma mb

      halfMHelper :: Maybe Int -> Maybe Int
      halfMHelper (Just a)
        = halfM a

      halfMHelper _
        = Nothing

      divideMHelper :: Maybe Int -> Maybe Int -> Maybe Int
      divideMHelper (Just a) (Just b)
        = divideM a b

      divideMHelper _ _
        = Nothing

--  We may be tempted to eliminate those helper functions through some cheeky
--  pattern matching (pattern matching is good, right?), viz.:

fStupid :: Int -> Maybe Int
fStupid x
  = Just c
    where
      Just a = squareRootM x
      Just b = halfM a
      Just c = divideM a b

--  But we've just reintroduced 'error' -- if 'Nothing' appears at any point,
--  we'll get a pattern match failure, and the program will crash. If only we
--  had a syntax that could capture the cases we care about and ignore the
--  'Nothing's for us. Something like:
--
--  fDo x = do
--    a <- squareRootM x
--    b <- halfM a
--    divideM a b
--
--  That would be great -- we've captured the essence of the program and left
--  the language to handle the cases where 'Nothing' appears. But that's just a
--  pipe dream, right? Surely we don't have the plumbing to construct such a
--  lovely thing...
--
--  Not yet. But let's recap last week's lecture, which gave us some
--  tools for working with funky types like 'Maybe' (which take other types as
--  arguments):
--
--  class Functor f where
--    fmap  :: (a -> b) -> f a -> f b
--
--  class Functor f => Applicative f where
--    pure  :: a -> f a
--    (<*>) :: f (a -> b) -> f a -> f b
--
--  Considering just 'Int's for a moment, we can illustrate what these
--  functions do with a diagram:
--
--             squareRootM
--   Int  ------------------->  M Int
--    |                           |
--    | pure                      | pure
--    |                           |
--    v     fmap squareRootM      v
--  M Int -------------------> M (M Int)
--
--  Hmm. This might work. Let's take the example of composing 'squareRootM'
--  and 'halfM' (abbreviating 'Maybe' to 'M'):
--
--                              halfM
--                        Int --------> M Int
--
--                        XXX
--        squareRootM
--  Int --------------> M Int
--
--  They nearly line up, but the domain of 'halfM' is wrong.
--
--  Aha! We can use 'fmap' to "fix" 'halfM':
--
--        squareRootM           fmap halfM
--  Int --------------> M Int -------------> M (M Int)
--
--  Looking good -- 'fmap' has "lifted" 'halfM' to work in a domain where
--  failure is possible. Unfortunately, the output is a bit too complicated --
--  it's of type 'M (M Int)', which encodes a bit more failure than we'd like.
--  We need some operation that just discards the extra cruft; something that
--  "joins" the two layers of 'M' together:
--
--        squareRootM           fmap halfM                join
--  Int --------------> M Int -------------> M (M Int) --------> M Int
--
--  Let's write 'join':
--
--  join :: M (M Int) -> M Int
--  join (Just x) = x
--  join Nothing  = Nothing
--
--  Perfect. Now we can glue together arbitrary sequences of our 'Maybe'
--  functions using 'fmap' and 'join':
--
--  join (fmap squareRootM (join (fmap halfM (squareRootM 16))))
--
--  It seems like adding the 'join' operation has given us a *new kind of
--  power* -- that of composing functions that have funky types. Neat!
--
--  It's getting a bit syntactically cumbersome though. And 'join' and 'fmap'
--  are like a pair of inseparable children -- they're always cropping up
--  together. Let's just define a shortcut:
--
--        squareRootM           fmap halfM                join
--  Int --------------> M Int -------------> M (M Int) --------> M Int
--                        v                                       ^
--                        |             (>>= halfM)               |
--                        +---------------------------------------+
--
--  We pronounce this shortcut "bind" (for reasons we'll elaborate on shortly),
--  and it's very important to note that it's parameterised by the function
--  that we would have passed to 'fmap'. Consequently we can assign "bind"
--  (>>=) the following type:
--
--  (>>=) :: M Int -> (Int -> M Int) -> M Int
--
--  And using it, rewrite 'f' as follows (using anonymous lambdas -- see
--  footnote 1):

fBind :: Int -> Maybe Int
fBind x
  = squareRootM x >>= (\a ->
      halfM a >>= (\b ->
        divideM a b))

--  Which certainly feels more succinct than that which we've seen thus far,
--  whilst not compromising on handling 'Nothing'. In fact, it's so succinct
--  that we typically define (>>=) directly, rather than in terms of 'fmap'
--  and 'join':
--
--  (>>=) :: M Int -> (Int -> M Int) -> M Int
--  Just x  >>= f = f x
--  Nothing >>= f = Nothing
--
--  As opposed to:
--
--  m >>= f
--    = join (fmap f m)
--
--  In fact, if we stare at it long enough, it's more than just succinct; it's
--  oddly familiar...
--
--  ~ Begin flashback ~
--
--  fDo x = do                fBind x =
--    a <- squareRootM x        squareRootM x >>= \a ->
--    b <- halfM a                halfM a >>= \b ->
--    divideM a b                   divideM a b
--
--  ~ End flashback ~
--
--  At this point, you might just be thinking "no way". Way. Way, way, way.
--  This is *exactly* the mechanism we need for building this "do-notation"!
--  "Bind" is so called because it lets us "bind" new variables and create nice
--  compositional blocks of code!
--
--  Check it out:

fDo :: Int -> Maybe Int
fDo x = do
  a <- squareRootM x
  b <- halfM a
  divideM a b

--  Type it. Run it. That's real code that really works! Isn't it magical? Yes,
--  deeply magical. But the gift keeps on giving! Note that (>>=)'s definition
--  doesn't rely on 'Int' at all! It can be made totally polymorphic!
--
--  (>>=) :: M a -> (a -> M b) -> M b
--
--  Phew.
--
--  Don't worry, there's a clearing up ahead -- we'll rest there for a bit.
--
--  ~
--
--  At this point it's time to unleash the final surprise that (>>=) has in
--  store for us. Take that "<-" syntax, for example -- we've seen that before:
--
--  [(x, y) | x <- [1..10], y <- [2,4..20]]
--
--  Could it be? Could list comprehensions really be (>>=) in disguise? Let's
--  see:

pairsListComp :: [Int] -> [Int] -> [(Int, Int)]
pairsListComp xs ys
  = [(x, y) | x <- xs, y <- ys]

pairsDo :: [Int] -> [Int] -> [(Int, Int)]
pairsDo xs ys = do
  x <- xs
  y <- ys
  pure (x, y)

youMustBeJoking :: [Int] -> [Int] -> Bool
youMustBeJoking xs ys
  = pairsListComp xs ys == pairsDo xs ys

--  Note: We had to use 'pure' to make the types line up.  The result is of
--  type '[(Int, Int)]', but '(x, y)' is of type '(Int, Int)'. 'pure' lets us
--  lift a "pure" result into a new domain (here that of lists, where many
--  results could exist).
--
--  "But wait!", you say; "For this to work, (>>=) must have a more general type than:
--
--  (>>=) :: M a -> (a -> M b) -> M b
--
--  Right?"
--
--  Indeed. But what have we done? Well, let's see:
--
--  (>>=) :: Maybe  a -> (a -> Maybe  b) -> Maybe a
--  (>>=) :: []     a -> (a -> []     b) -> []    b
--
--  You might see that this is precisely the trick we played with 'Functor' and
--  'Applicative'. Well, we're going to play it again. Behold:
--
--  class Monad m where
--    return  :: a -> m a
--    (>>=)   :: m a -> (a -> m b) -> m b
--
--  A 'Monad' is an 'Applicative' that's been *powered up* by a (>>=) operation
--  (or as we first saw, a 'join' operation). Such a power up gives us the
--  ability to chain arbitrary computations together and regain
--  compositionality. 'return' is the same as 'pure', but is there mainly for
--  historical reasons. It also provides a degree of comfort to imperative
--  programmers.
--
--  With the final secret revealed, let's see the instances for 'Maybe' and
--  '[]' (both defined in the Prelude, should you find yourself itching to use
--  them):
--
--  instance Monad Maybe where
--    return :: a -> Maybe a
--    return
--      = Just
--
--    (>>=) :: Maybe a -> (a -> Maybe b) -> Maybe b
--    Just x >>= f
--      = f x
--
--    Nothing >>= f
--      = Nothing
--
--  instance Monad [] where
--    return :: a -> [a]
--    return x
--      = [x]
--
--    (>>=) :: [a] -> (a -> [b]) -> [b]
--    (>>=)
--      = flip concatMap
--
--  To see that (>>=) in the list monad is 'flip concatMap', recall that (>>=)
--  is defined by first 'fmap'ping, and then 'join'ing. We know that:
--
--  instance Functor [] where
--    fmap
--      = map
--
--  And join :: [[a]] -> [a], which looks like 'concat'. So (>>=) is indeed a
--  'map' followed by a 'concat' -- a 'concatMap'.
--
--  ~
--
--  It seems that the last thing to do is to give a piece of code which is
--  truly polymorphic. Indeed, this is the real power of the do-notation -- it
--  works for *any* monad!

anyMonad :: Monad m => m Int -> m Int -> m (Int, Int)
anyMonad mx my = do
  a <- mx         -- mx >>= \a ->
  b <- my         --  my >>= \b ->
  return (a, b)   --    return (a, b)

maybeMonad :: Maybe Int -> Maybe Int -> Maybe (Int, Int)
maybeMonad
  = anyMonad

listMonad :: [Int] -> [Int] -> [(Int, Int)]
listMonad
  = anyMonad

--  Monads are truly a beautiful piece of kit, and we'll be exploring their
--  full power in the coming weeks. If you want some more problems to get your
--  teeth into in the meantime, consider these:
--
--  1.  'Maybe' is nice, but it doesn't tell you *what* went wrong. 'Either' is
--      a data type which lets you say a bit more when something goes awry:
--
--      data Either a b
--        = Left a
--        | Right b
--
--      One can read the type 'Either String b' as a value which returns an 'a'
--      when successful or a 'String' containing an error message on failure.
--      Try and write 'Functor', 'Applicative' and 'Monad' instances for the
--      type constructor (Either String). I.e.,
--
--      instance Functor (Either String) where
--        ...
--
--      ...
--
--  2.  I showed you that one could define (>>=) using 'fmap' and 'join', but
--      then argued that we typically just write (>>=) directly. To prove that
--      we've not sacrificed any power in doing so, can you write 'join' using
--      (>>=)? That is:
--
--      join :: Monad m => m (m a) -> m a
--      join
--        = ... Something using (>>=) ...
--
--  ~
--
--  Footnote 1: Anonymous lambdas
--
--  It can be annoying when one has to write helper functions all the time.
--  This problem is compounded by (>>=), where every other argument is a
--  function. Consequently it becomes immensely helpful to create functions
--  "on-the-fly". Anonymous lambdas let you do this. Contrast the following:
--
--  let p x = x > 2 && even x
--  in  filter p xs
--
--  filter (\x -> x > 2 && even x) xs
--
--  The (\x -> ...) is an anonymous lambda (so-called because it has no name).

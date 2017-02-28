module IO where

--  We'll begin by looking again at the Monad typeclass:
--
--  class Monad m where
--    return  :: a -> m a
--    (>>=)   :: m a -> (a -> m b) -> m b
--
--  Recall that the point of (>>=) (pronounced ``bind'') is to chain together
--  computations. Specifically, computations which have side effects. In the
--  case of Maybe, the side effect is that failure might occur (i.e. some
--  function returns Nothing). Bind's job in this scenario is to pass the
--  Nothing through, so that the end result of the whole computation is
--  Nothing:
--
--  instance Monad Maybe where
--    return        = Just
--
--    Nothing >>= f = Nothing
--    Just x  >>= f = f x
--
--  For example:

half :: Int -> Maybe Int
half x
  | even x    = Just (x `div` 2)
  | otherwise = Nothing

safeDiv :: Int -> Int -> Maybe Int
safeDiv x y
  | y == 0    = Nothing
  | otherwise = Just (x `div` y)

--  Haskell's ``do-notation'' is a syntactic-sugar for writing monadic code. We
--  can write a function that uses both `half' and `safeDiv' as follows:

test x =
  do
    y <- half x
    z <- safeDiv x y
    return (x * z)

--  This ``desugars'' (i.e. is converted by the compiler) to the following
--  code, in terms of bind and anonymous lambdas:

test' x =
  half x >>= \y ->
    safeDiv x y >>= \z ->
      return (x * z)

--  Anyway. That's enough of Maybe. We're interested in input and output (I/O).
--  How do we do it? Well, let's start with some simple pure functions:

f :: Int -> Int
f x
  = 2 * x

g :: Int -> Int
g x
  = x + 1

--  Great. But now we want to print out some stuff when these functions run.
--  But in Haskell, the only way a function can have some useful effect is to
--  return something interesting. So I guess the best we can do is return the
--  String we want printed (we'll assume that some magic* happens and that
--  Strings returned are printed for us):

f' :: Int -> (Int, String)
f' x
  = (2 * x, "f'")

g' :: Int -> (Int, String)
g' x
  = (x + 1, "g'")

--  It's getting quite ugly already. But we'll plough on. Alas, there is an
--  issue. Recall that in Haskell, functions are /pure/. Loosely this means
--  that if you give a function the same inputs, it always gives you the same
--  answer. However, if I give f' and g' the same inputs, the console (where
--  the two functions are printing their strings to) might look *different*
--  depending on what it looked like *before* I called f'/g'.
--
--  But we can get around this -- we simply need to pass in the console's state
--  to the function. That way, when we give the same input and console, we get
--  the same output and console -- the function is pure again! To see what I
--  mean, consider the console as just being a list of strings (which have been
--  printed). I'll generalise and consider the ``whole world'', which is surely
--  a superset of the console:

type World
  = [String]

f'' :: Int -> World -> (Int, World)
f'' x w
  = (2 * x, w ++ ["f''"])

g'' :: Int -> World -> (Int, World)
g'' x w
  = (x + 1, w ++ ["g''"])

--  Ugly, but we're nice and pure again. Chaining f'' and g'' together is no
--  mean feat though -- we have to make sure we pass the worlds through
--  ourselves:

fg
  = let (x, w)  = f'' 3 []
        (y, w') = g'' x w
    in  f'' y w'

--  Let's hope no-one's looking over our shoulders at this monstrosity. We need
--  to get back to beautiful code. Specifically, we want to go back to our
--  beautiful f and g, where we didn't *care* about the world at all (or as
--  near as possible, at least). Perhaps something like (<cough>Java</cough>):
--
--  f''' x =
--    do
--      print "f'''"
--      return (2 * x)
--
--  ...
--
--  fg' =
--    do
--      x <- f'' 3
--      y <- g'' x
--      f'' y
--
--  That's the same trick we played with Maybe (!) -- if we could write it like
--  this, we could make bind (>>=) do all the horrible threading for us.
--  Additionally, we can hide the world by providing functions like print. But
--  how do we write bind?
--
--  Well, to try and get an intuition, recall what (>>=) did for Maybe. It let
--  us forget that there was the possibility that the argument could be Nothing
--  or Just x (for some x). Here, we want to forget the world. To see what I
--  mean, consider that we could ``forget'' the world from the definition of f
--  by pushing it inside and returning an anonymous lambda:

f''' :: Int -> World -> (Int, World)
f''' x
  = \w -> (2 * x, w ++ ["f'''"])

--  So the trick to ignoring the world is to push it inside. Effectively, we're
--  ``putting the brackets back into the type'':
--
--  f''' :: Int -> (World -> (Int, World))
--
--  So f''' takes an Int (only) and gives back a function that can take a
--  world and act accordingly. This (hopefully) gives us an intuition of
--  bind's grounded type:
--
--  (>>=) :: (World -> (Int, World))
--        -> (Int -> (World -> (Int, World)))
--        -> (World -> (Int, World))
--
--  Whoah. Before we completely go blind, let's recall that we can lose a few
--  of those brackets, because arrow (->) is right-associative:
--
--  (>>=) :: (World -> (Int, World))
--        -> (Int -> World -> (Int, World))
--        -> World
--        -> (Int, World)
--
--  So bind takes a function of type (World -> (Int, World)), another function
--  of type (Int -> World -> (Int, World)) and a world to kick it off, and
--  gives you back the result and a new world that's been through both
--  computations. So:
--
--  (>>=) f g w
--    = ...
--
--  Well, we have f :: World -> (Int, World)
--                g :: Int -> World -> (Int, World)
--                w :: World
--
--  All we can do first is pass w to f:
--
--  (>>=) f g w
--    = let (x, w') = f w
--      in  ...
--
--  Now we've got an Int and a new World. Well, let's pass them to g -- that
--  seems sensible:
--
--  (>>=) f g w
--    = let (x, w') = f w
--      in  g x w'
--
--  And we're done! Bind actually writes itself! Return is not too bad either:
--
--  return :: Int -> (World -> (Int, World))
--
--  Well, we can remove one set of brackets again:
--
--  return :: Int -> World -> (Int, World)
--
--  So:
--
--  return x w
--    = (x, w)
--
--  Or, return = (,). Which is a particularly beautiful result, you might
--  think!
--
--  Anyway. We've got return, and we've got bind (>>=). These are members of
--  Monad; for some m:
--
--  return  :: a -> m a
--  (>>=)   :: m a -> (a -> m b) -> m b
--
--  What's the m? Well, in our examples, both a and b are Int, so let's work
--  backwards. I'll use return, since it's simpler:
--
--  return :: Int -> (World -> (Int, World))
--  return :: a   -> (World -> (a  , World))
--
--  Ahah! We'll just bundle that up into a type synonym:
--
--  type IO a
--    = World -> (a, World)
--
--  Now, return and (>>=) have nicer types:
--
--  return  :: a -> IO a
--  (>>=)   :: IO a -> (a -> IO b) -> IO b
--
--  Isn't that incredible?!
--
--  1.  We can hide a function arrow behind a type synonym!
--
--  2.  Because (->) is right-associative, the types unfold transparently into
--      new functions!
--
--  3.  Because we've hidden the World behind a type synonym, people can't mess
--      around with past/future versions of the world!
--
--  Point 3 is of particular note. For example, before, we could have been
--  cruel (and highly unusual) and decided to use g's results without taking
--  into account its effects:

fgCruel
  = let (x, w)  = f'' 3 []
        (y, w') = g'' x w
    in  f'' y w

--  Now that we can't see the world, we're no longer in this position to abuse
--  it. Excellent.
--
--  But now we have a new question -- values of type IO a are actually
--  functions that need a world. So to run them, we need a starting world. But
--  we don't know what worlds look like (we hid them behind type synonyms)!
--
--  In fact, this is perfect. Because, as much as I'd like to say I know what
--  the starting world looks like, I don't. I can't. Only the operating system
--  that started my program can! Consequently, the starting world can only be
--  provided once -- at the *start of the program*. Like in Java, the start
--  function in Haskell is called main, and has type IO ():

main :: IO ()
main =
  do
    print "Awesome, I'm doing IO!"

--  Main is the only function that gets a starting world. All other IO
--  functions must be called from inside it, and they in turn will receive the
--  worlds they need in the order they are called.
--
--  Furthermore (it keeps getting better!), *any* function that uses IO *must*
--  have IO in its type, right? Because otherwise it's not got a world it can
--  pass to the functions it wants to call. So I can determine which functions
--  do IO *just by looking at their types*.
--
--  *Stunned pause*
--
--  This is one of the most beautiful properties of monadic IO. Well, I think
--  it is. IO is infectious -- you can't do it unless you're willing to accept
--  people will know you've done it (heinous!). For example:

bePolite :: IO ()
bePolite =
  do
    putStrLn "Hello, what's your name?"
    name <- getLine
    putStrLn $ "Hello " ++ name

--  bePolite *has to have IO* as its result type. To see why, consider the
--  desugared version:

bePolite' :: IO ()
bePolite'
  = putStrLn "Hello, what's your name?" >>= \_ ->
      getLine >>= \name ->
        putStrLn ("Hello " ++ name)

--  Bind's type says that we have to have a world with which to execute
--  putStrLn, getLine and then putStrLn. We can't do that unless we're already
--  in IO. So our type must also end in IO. Amazing.
--
--  So that's it.
--
--  Well, not quite. IO is first class, so all the things that Java gives us
--  with keywords can actually be expressed as functions! Consider the
--  so-called `enhanced' for-loop, for example:
--
--  for (String s : ss) {
--    // Do something with s...
--  }
--
--  It looks a bit like a map, doesn't it? Well, let's see:
--
--  ghci> :t map
--  map :: (a -> b) -> [a] -> [b]
--  ghci> :t print
--  print :: Show a => a -> IO ()
--  ghci> :t map print
--  map print :: Show a => [a] -> [IO ()]
--
--  So close! What we really want is some `monadic map', mapM, say, that has
--  the correct type:
--
--  ghci> :t mapM
--  mapM :: Monad m => (a -> m b) -> [a] -> m [b]
--  ghci> :t print
--  print :: Show a => a -> IO ()
--  ghci> :t mapM print
--  mapM print :: Show a => [a] -> IO [()]
--
--  Well, let's write it:
--
--  mapM :: Monad m => (a -> m b) -> [a] -> m [b]
--  mapM f []
--    = return []
--
--  mapM f (x : xs) = do
--    y <- f x
--    ys <- mapM f xs
--    return (y : ys)
--
--  That's pretty much a for-loop! What's that? The arguments are the wrong way
--  around? Oh, go on then...
--
--  forM :: Monad m => [a] -> (a -> m b) -> m [b]
--  forM
--    = flip mapM
--
--
--  Ta-da!
--
--  As a last nugget of perfection, note the ``>>= \_ ->'' pattern that's
--  cropping up everywhere. This is common -- plenty of IO actions (copy a file,
--  delete a disk, load an image) are just that -- actions. They don't return
--  anything (or rather they return (), pronounced ``unit'', which conveys no
--  information) and so the argument to bind's function is ignored.
--  Consequently there is a version of bind (which I pronounce ``then'') which
--  does this ignorning bit for us:
--
--  (>>) :: m a -> m b -> m b
--  ma >> mb
--    = ma >>= \_ -> mb
--
--  (Or: ma >> mb = ma >>= const mb!)
--
--  Note that (>>) is the same as `;' in many imperative languages! (Ok, so is
--  bind to some extent, but be quiet and enjoy the analogy). Nothing is built
--  in! There is magic!*
--
--  *There isn't actually any magic.

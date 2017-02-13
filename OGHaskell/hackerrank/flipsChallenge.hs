--flip challenge commence
--NOTE: flip takes a maximum of 3 arguments
--NOTE: flip :: (a -> b -> c) -> b -> a -> c
--      in this definition, any of these things can be functions

test :: a -> b -> c -> (a,b,c)
test x y z
  = (x, y, z)

test' :: a -> a -> a -> a -> [a]
test' x y z a
  = [x,y,z,a]

flip1 :: (a -> b -> c -> x) -> (a -> b -> c -> x)
flip1
  = id

flip2 :: (a -> b -> c -> x) -> (a -> c -> b -> x)
flip2
  = (flip .)

flip3 :: (a -> b -> c -> x) -> (b -> a -> c -> x)
flip3
  = flip

flip4 :: (a -> b -> c -> x) -> (b -> c -> a -> x)
--type signature is odd
flip4
  = (flip .) . flip

flip5 :: (a -> b -> c -> x) -> (c -> a -> b -> x)
--type signature is odd
flip5
  = flip . (flip .)

flip6 :: (a -> b -> c -> x) -> (c -> b -> a -> x)
flip6
  = (flip .) . (flip . (flip .))

--flip1' :: (a -> b -> c -> d -> x) -> (b -> a -> c -> d -> x)
flip1'
  = flip

--flip2' :: (a -> b -> c -> d -> x) -> (a -> b -> d -> c -> x)
flip2'
  = (flip .)

flip3' f a b c d
  = flip (f a b) c d

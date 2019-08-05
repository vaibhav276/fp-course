{-# LANGUAGE InstanceSigs        #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Course.Extend where

import           Course.Core
import           Course.ExactlyOne
import           Course.Functor
import           Course.List
import           Course.Optional

-- | All instances of the `Extend` type-class must satisfy one law. This law
-- is not checked by the compiler. This law is given as:
--
-- * The law of associativity
--   `∀f g. (f <<=) . (g <<=) ≅ (<<=) (f . (g <<=))`
class Functor f => Extend f where
  -- Pronounced, extend.
  (<<=) ::
    (f a -> b)
    -> f a
    -> f b

infixr 1 <<=

-- | Implement the @Extend@ instance for @ExactlyOne@.
--
-- >>> id <<= ExactlyOne 7
-- ExactlyOne (ExactlyOne 7)
instance Extend ExactlyOne where
  (<<=) ::
    (ExactlyOne a -> b)
    -> ExactlyOne a
    -> ExactlyOne b
  (<<=) eoab eoa = ExactlyOne $ eoab eoa

-- | Implement the @Extend@ instance for @List@.
--
-- >>> length <<= ('a' :. 'b' :. 'c' :. Nil)
-- [3,2,1]
--
-- >>> id <<= (1 :. 2 :. 3 :. 4 :. Nil)
-- [[1,2,3,4],[2,3,4],[3,4],[4]]
--
-- >>> reverse <<= ((1 :. 2 :. 3 :. Nil) :. (4 :. 5 :. 6 :. Nil) :. Nil)
-- [[[4,5,6],[1,2,3]],[[4,5,6]]]
instance Extend List where
  (<<=) ::
    (List a -> b)
    -> List a
    -> List b
  (<<=) _ (Nil) = Nil
  (<<=) lab la  = (lab la) :. ((<<=) lab (drop 1 la))

-- | Implement the @Extend@ instance for @Optional@.
--
-- >>> id <<= (Full 7)
-- Full (Full 7)
--
-- >>> id <<= Empty
-- Empty
instance Extend Optional where
  (<<=) ::
    (Optional a -> b)
    -> Optional a
    -> Optional b
  (<<=) oab oa = case oa of
    Full _ -> Full $ oab oa
    Empty  -> Empty

-- | Duplicate the functor using extension.
--
-- >>> cojoin (ExactlyOne 7)
-- ExactlyOne (ExactlyOne 7)
--
-- >>> cojoin (1 :. 2 :. 3 :. 4 :. Nil)
-- [[1,2,3,4],[2,3,4],[3,4],[4]]
--
-- >>> cojoin (Full 7)
-- Full (Full 7)
--
-- >>> cojoin Empty
-- Empty
cojoin ::
  Extend f =>
  f a
  -> f (f a)
cojoin =
  error "todo: Course.Extend#cojoin"

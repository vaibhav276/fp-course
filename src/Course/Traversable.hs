{-# LANGUAGE InstanceSigs        #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Course.Traversable where

import           Course.Applicative
import           Course.Compose
import           Course.Core
import           Course.ExactlyOne
import           Course.Functor
import           Course.List
import           Course.Optional

-- | All instances of the `Traversable` type-class must satisfy three laws. These
-- laws are not checked by the compiler. These laws are given as:
--
-- * The law of naturality
--   `∀f g. f . traverse g ≅ traverse (f . g)`
--
-- * The law of identity
--   `∀x. traverse ExactlyOne x ≅ ExactlyOne x`
--
-- * The law of composition
--   `∀f g. traverse ((g <$>) . f) ≅ (traverse g <$>) . traverse f`
class Functor t => Traversable t where
  traverse ::
    Applicative f =>
    (a -> f b)
    -> t a
    -> f (t b)

instance Traversable List where
  traverse ::
    Applicative f =>
    (a -> f b)
    -> List a
    -> f (List b)
  traverse f =
    foldRight (\a b -> (:.) <$> f a <*> b) (pure Nil)

instance Traversable ExactlyOne where
  traverse ::
    Applicative f =>
    (a -> f b)
    -> ExactlyOne a
    -> f (ExactlyOne b)
  traverse f eoa = ExactlyOne <$> f (runExactlyOne eoa)

instance Traversable Optional where
  traverse ::
    Applicative f =>
    (a -> f b)
    -> Optional a
    -> f (Optional b)
  traverse f (Full x) = Full <$> f x
  traverse _ Empty    = pure Empty

-- | Sequences a traversable value of structures to a structure of a traversable value.
--
-- >>> sequenceA (ExactlyOne 7 :. ExactlyOne 8 :. ExactlyOne 9 :. Nil)
-- ExactlyOne [7,8,9]
--
-- >>> sequenceA (Full (ExactlyOne 7))
-- ExactlyOne (Full 7)
--
-- >>> sequenceA (Full (*10)) 6
-- Full 60
sequenceA ::
  (Applicative f, Traversable t) =>
  t (f a)
  -> f (t a)
sequenceA = traverse id

instance (Traversable f, Traversable g) =>
  Traversable (Compose f g) where
-- Implement the traverse function for a Traversable instance for Compose
  traverse :: (Applicative h) =>
    (a -> h b)
    -> Compose f g a
    -> h (Compose f g b)
  traverse x (Compose fga) =
    Compose <$> traverse (traverse x) fga

-- | The `Product` data type contains one value from each of the two type constructors.
data Product f g a =
  Product (f a) (g a) deriving (Show, Eq)

instance (Functor f, Functor g) =>
  Functor (Product f g) where
-- Implement the (<$>) function for a Functor instance for Product
  (<$>) ::
    (a -> b)
    -> Product f g a
    -> Product f g b
  (<$>) x (Product fa ga) = Product (x <$> fa) (x <$> ga)

instance (Traversable f, Traversable g) =>
  Traversable (Product f g) where
-- Implement the traverse function for a Traversable instance for Product
  traverse :: (Applicative h) =>
    (a -> h b)
    -> Product f g a ->
    h (Product f g b)
  traverse x (Product fa ga) =
    Product <$> traverse x fa <*> traverse x ga

-- | The `Coproduct` data type contains one value from either of the two type constructors.
data Coproduct f g a =
  InL (f a)
  | InR (g a) deriving (Show, Eq)

instance (Functor f, Functor g) =>
  Functor (Coproduct f g) where
-- Implement the (<$>) function for a Functor instance for Coproduct
  (<$>) ::
    (a -> b)
    -> Coproduct f g a
    -> Coproduct f g b
  (<$>) x (InL fa) = InL $ x <$> fa
  (<$>) x (InR ga) = InR $ x <$> ga

instance (Traversable f, Traversable g) =>
  Traversable (Coproduct f g) where
-- Implement the traverse function for a Traversable instance for Coproduct
  traverse :: Applicative h =>
    (a -> h b)
    -> Coproduct f g a
    -> h (Coproduct f g b)
  traverse x (InL fa) = InL <$> traverse x fa
  traverse x (InR ga) = InR <$> traverse x ga

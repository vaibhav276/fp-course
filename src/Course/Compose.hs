{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Course.Compose where

import           Course.Applicative
import           Course.Core
import           Course.Functor
import           Course.Monad

-- Exactly one of these exercises will not be possible to achieve. Determine which.

newtype Compose f g a =
  Compose (f (g a)) deriving (Show, Eq)

-- Implement a Functor instance for Compose
instance (Functor f, Functor g) =>
    Functor (Compose f g) where
  (<$>) f (Compose fga) = Compose ((f <$>) <$> fga)

instance (Applicative f, Applicative g) =>
  Applicative (Compose f g) where
-- Implement the pure function for an Applicative instance for Compose
  pure = Compose . pure . pure
-- Implement the (<*>) function for an Applicative instance for Compose
  -- (<*>) (Compose fgf) (Compose fga) = Compose (((<*>) <$> fgf) <*> fga)
  (<*>) (Compose fgf) (Compose fga) = Compose (lift2 (<*>) fgf fga)

instance (Monad f, Monad g) =>
  Monad (Compose f g) where
-- Implement the (=<<) function for a Monad instance for Compose
  (=<<) =
    -- error "todo: Course.Compose (<<=)#instance (Compose f g)"
    error "impossible"

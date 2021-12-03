module Monads where

import AST

class Monad m => MonadState m where
    lookforVar :: String -> m Atom
    updateVar :: String -> Atom -> m ()

    lookforCell :: (Int,Int) -> m Cell 
    updateCell :: (Int,Int) -> Cell -> m ()

    updatePlayer :: Player -> m ()
    getMapSize :: m Cell

class Monad m => MonadError m where
    throw :: Error -> m a 
module Monads where

import AST

class Monad m => MonadState m where
    lookforVar :: String -> m Atom
    updateVar :: String -> Atom -> m ()

    lookforCell :: (Int,Int) -> m Cell 
    updateCell :: (Int,Int) -> Cell -> m ()

    updatePlayer :: Player -> m ()
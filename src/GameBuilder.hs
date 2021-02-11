module GameBuilder where

import AST
import Data.Map.Strict as M 
import Data.Maybe
import Parser 
import Control.Monad
import Monads

-- Entornos de almacenamiento

type VarEnv = M.Map String Atom
type MapEnv = M.Map (Int,Int) Cell

-- Inicializadores de entornos
initVarEnv :: VarEnv
initVarEnv = M.empty

initMapEnv :: MapEnv
initMapEnv = M.empty


-- Monada de estado
newtype State a = State {runState :: VarEnv -> MapEnv -> (a, VarEnv, MapEnv) }

instance Monad State where
  return x = State (\v m -> (x,v,m))
  a >>= f = State (\v m -> let (x,v',m') = runState a v m in runState (f x) v' m') 

instance Functor State where
  fmap = liftM

instance Applicative State where
  pure = return 
  (<*>) = ap

instance MonadState State where
  lookforVar s = State (\v m -> (lookfor' s v,v,m)) where lookfor' s v = fromJust $ M.lookup s v
  lookforCell s = State (\v m -> (lookfor' s m,v,m)) where lookfor' s m = fromJust $ M.lookup s m

  updateVar s a = State (\v m -> ((),update' s a v, m)) where update' = M.insert
  updateCell s a = State (\v m -> ((),v, update' s a m)) where update' = M.insert   
-- Evaluador

eval :: [Comm] -> (VarEnv, MapEnv)
eval [x] = (v,m) where (_,v,m) = runState (evalComm x) initVarEnv initMapEnv
eval (x:xs) = let (v,m) = eval xs
                  (_,v',m') = runState (evalComm x) v m
              in (v',m')

evalComm :: MonadState m => Comm -> m () 
evalComm (Assign s v) = case v of
                          Var x -> do var <- lookforVar x 
                                      updateVar s var
                          n -> do updateVar s n
evalComm (CreatePlayer p) = undefined
evalComm (CreateCell x y c) = do updateCell (x,y) c
evalComm (CreateMap m) = undefined
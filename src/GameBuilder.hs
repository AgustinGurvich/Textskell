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

initPlayer :: Player
initPlayer = Player (-1) (-1) (-1) (-1)

-- Monada de estado
newtype State a = State {runState :: VarEnv -> MapEnv ->  Player ->(a, VarEnv, MapEnv,Player) }

instance Monad State where
  return x = State (\v m p -> (x,v,m,p))
  a >>= f = State (\v m p -> let (x,v',m',p) = runState a v m p in runState (f x) v' m' p) 

instance Functor State where
  fmap = liftM

instance Applicative State where
  pure = return 
  (<*>) = ap

instance MonadState State where
  lookforVar s = State (\v m p -> (lookfor' s v,v,m,p)) where lookfor' s v = fromJust $ M.lookup s v 
  lookforCell s = State (\v m p -> (lookfor' s m,v,m,p)) where lookfor' s m = fromJust $ M.lookup s m

  updateVar s a = State (\v m p -> ((),update' s a v, m,p)) where update' = M.insert
  updateCell s a = State (\v m p -> ((),v, update' s a m,p)) where update' = M.insert  
  updatePlayer s = State (\v m p -> ((),v,m,s)) 
 
-- Evaluador

eval :: [Comm] -> (VarEnv,MapEnv,Player)
eval c = eval' c initVarEnv initMapEnv initPlayer

eval' :: [Comm] -> VarEnv -> MapEnv -> Player -> (VarEnv,MapEnv,Player)
eval' [x] var map player = (v,m,p) where (_,v,m,p) = runState (evalComm x) var map player
eval' (x:xs) var map player = let (_,v,m,p) = runState (evalComm x) var map player in eval' xs v m p  

evalComm :: MonadState m => Comm -> m () 
evalComm (Assign s v) = case v of
                          Var x -> do var <- lookforVar x 
                                      updateVar s var
                          n -> do updateVar s n
evalComm (CreatePlayer p) = updatePlayer p
evalComm (CreateCell x y c) = do updateCell (x,y) c
evalComm (CreateMap m) = undefined

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

-- Monada de estado con manejo de errores
newtype StateError a = StateError {runStateError :: VarEnv -> MapEnv ->  Player -> Either Error (a, VarEnv, MapEnv,Player)}

instance Functor StateError where
  fmap = liftM

instance Applicative StateError where
  pure = return 
  (<*>) = ap

instance Monad StateError where
  return x = StateError (\v m p -> Right (x,v,m,p))
  a >>= f = StateError (\v m p -> runStateError a v m p >>= \(x,v',m',p') -> runStateError (f x) v' m' p')

instance MonadError StateError where
  throw e = StateError (\v m p -> Left e)

instance MonadState StateError where
  lookforVar s = StateError (\v m p -> case M.lookup s v of
                                        Nothing -> Left UndefVar
                                        Just x -> Right(x,v,m,p))
  lookforCell s = StateError (\v m p -> case M.lookup s m of
                                        Nothing -> Left UndefCell
                                        Just x -> Right(x,v,m,p))
  
  updateVar s a = StateError (\v m p -> Right ((),update' s a v, m,p)) where update' = M.insert
  updateCell s a = StateError (\v m p -> Right ((),v, update' s a m,p)) where update' = M.insert
  updatePlayer s = StateError (\v m p -> Right ((),v,m,s)) 

--Evaluador

eval :: [Comm] -> Either Error (VarEnv,MapEnv,Player)
eval c = eval' c initVarEnv initMapEnv initPlayer

eval' :: [Comm] -> VarEnv -> MapEnv -> Player -> Either Error (VarEnv,MapEnv,Player)
eval' [x] var map player = runStateError (evalComm x) var map player >>= \(_,v,m,p) -> return (v,m,p)
eval' (x:xs) var map player = runStateError (evalComm x) var map player >>= \(_,v,m,p) -> eval' xs v m p  

evalComm :: (MonadState m, MonadError m) => Comm -> m () 
evalComm (Assign s v) = case v of
                          Var x -> do var <- lookforVar x 
                                      updateVar s var
                          n -> do updateVar s n
evalComm (CreatePlayer p@(Player hp dmg x y)) = do  bound <- lookforCell (-1,-1)
                                                    case bound of
                                                      (CMapSize xbound ybound) -> if x < 0 || y < 0 || x >= xbound || y >= ybound then throw InvalidPos else if hp < 1 then throw InvalidValue else updatePlayer p 
                                                      _ -> throw InvalidPos
evalComm (CreateCell x y (CTreasure (Var v) s)) = do var <- lookforVar v
                                                     updateCell (x,y) (CTreasure var s)
evalComm (CreateCell x y (CEnemy (Var v) s)) = do var <- lookforVar v
                                                  updateCell (x,y) (CEnemy var s)
evalComm (CreateCell x y c) = do updateCell (x,y) c
evalComm (SetMapSize x y) = do updateCell (-1,-1) (CMapSize x y)
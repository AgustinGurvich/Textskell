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
type MenuEnv = M.Map Menu String

-- Inicializadores de entornos
initVarEnv :: VarEnv
initVarEnv = M.empty

initMapEnv :: (Int,Int) -> MapEnv
initMapEnv (xMax,yMax) = M.fromList $ Prelude.map (\x -> (x,CEmpty)) emptyMap 
          where emptyMap = concatMap (\x -> Prelude.map (\y -> (x,y)) [0..(yMax -1)]) [0..(xMax -1)]

initPlayer :: Player
initPlayer = Player (-1) (-1) (-1, -1)

initMenuEnv :: MenuEnv
initMenuEnv = M.empty

-- Monada de estado con manejo de errores
newtype StateError a = StateError {runStateError :: VarEnv -> MapEnv ->  Player -> MenuEnv ->Either Error (a, VarEnv, MapEnv,Player,MenuEnv)}

instance Functor StateError where
  fmap = liftM

instance Applicative StateError where
  pure = return 
  (<*>) = ap

instance Monad StateError where
  return x = StateError (\v m p c -> Right (x,v,m,p,c))
  a >>= f = StateError (\v m p c -> runStateError a v m p c >>= \(x,v',m',p',c') -> runStateError (f x) v' m' p' c')

instance MonadError StateError where
  throw e = StateError (\v m p c -> Left e)

instance MonadState StateError where
  lookforVar s = StateError (\v m p c -> case M.lookup s v of
                                        Nothing -> Left $ UndefVar s
                                        Just x -> Right(x,v,m,p,c))
  lookforCell s = StateError (\v m p c -> case M.lookup s m of
                                        Nothing -> Left $ UndefCell s
                                        Just x -> Right(x,v,m,p,c))
  lookforMenu s = StateError (\v m p c -> case M.lookup s c of
                                        Nothing -> Left $ UndefMenu s
                                        Just x -> Right(x,v,m,p,c))
  getMapSize = StateError (\v m p c -> Right (fromJust $ M.lookup (-1,-1) m,v,m,p,c) )
  updateVar s a = StateError (\v m p c -> Right ((),update' s a v, m,p,c)) where update' = M.insert
  updateCell s a = StateError (\v m p c -> Right ((),v, update' s a m,p,c)) where update' = M.insert
  updatePlayer s = StateError (\v m p c -> Right ((),v,m,s,c)) 
  updateMenu s a = StateError (\v m p c -> Right ((),v, m,p,update' s a c)) where update' = M.insert

--Evaluador

eval :: (Int, Int) -> [Comm] -> Either Error (VarEnv,MapEnv,Player,MenuEnv)
eval size c = eval' c initVarEnv (initMapEnv size) initPlayer initMenuEnv

eval' :: [Comm] -> VarEnv -> MapEnv -> Player -> MenuEnv -> Either Error (VarEnv,MapEnv,Player,MenuEnv)
eval' [] _ _ _  _ = Left $ InvalidValue "Archivo vacio"
eval' [x] var map player menu = runStateError (evalComm x) var map player menu >>= \(_,v,m,p,c) -> return (v,m,p,c)
eval' (x:xs) var map player menu = runStateError (evalComm x) var map player menu >>= \(_,v,m,p,c) -> eval' xs v m p c  

outOfBounds :: (Int,Int) -> (Int,Int) -> Bool 
outOfBounds (x,y) (xbound,ybound) = x < 0 || y < 0 || x >= xbound || y >= ybound

evalComm :: (MonadState m, MonadError m) => Comm -> m () 
evalComm (Assign s v) = case v of
                          Var x -> do var <- lookforVar x --Si la variable esta definida, la defino con otro nombre. Sino, se propaga solo el error
                                      updateVar s var
                          n -> do updateVar s n -- Creo la variable
evalComm (CreatePlayer p@(Player hp dmg (x,y))) = do mapa <- getMapSize --Busco los limites del mapa
                                                     let (CMapSize xbound ybound) = mapa
                                                     if outOfBounds (x,y) (xbound,ybound) then throw $ InvalidPos (x,y) else if hp < 1 || dmg < 0 then throw $ InvalidValue (show (hp,dmg)) else updatePlayer p 
evalComm (CreateCell x y (CTreasure (Var v) s)) = do var <- lookforVar v
                                                     mapa <- getMapSize 
                                                     let (CMapSize xbound ybound) = mapa
                                                     if outOfBounds (x,y) (xbound,ybound) then throw $ InvalidPos (x,y) else updateCell (x,y) (CTreasure var s)
evalComm (CreateCell x y (CEnemy (Var v) s)) = do var <- lookforVar v
                                                  mapa <- getMapSize
                                                  let (CMapSize xbound ybound) = mapa
                                                  if outOfBounds (x,y) (xbound,ybound) then throw $ InvalidPos (x,y) else updateCell (x,y) (CEnemy var s)
evalComm (CreateCell x y c) = do mapa <- getMapSize 
                                 let (CMapSize xbound ybound) = mapa
                                 if outOfBounds (x,y) (xbound,ybound) then throw $ InvalidPos (x,y) else updateCell (x,y) c -- Para las celdas vacias
evalComm (SetMapSize x y) = do updateCell (-1,-1) (CMapSize x y) -- Creo el tamaño del mapa
evalComm (SetMenu menu txt) = updateMenu (stringToMenu menu) txt
                              where stringToMenu "Title" = Title 
                                    stringToMenu "InvalidMovement" = InvalidMovement
                                    stringToMenu "Death"    = Death
                                    stringToMenu "EmptyCell" = EmptyCell
                                    stringToMenu "ExitMessage" = Exit
                                    stringToMenu "FightVictory" = FightVictory
                                    stringToMenu "CurrentPosition" = CurrentPos
                                    stringToMenu "EnemyHp" = EnemyHp 
                                    stringToMenu "EnemyDmg" = EnemyDmg
                                    stringToMenu "RunAway" = RunAway
                                    stringToMenu "InvalidOption" = InvalidOption
                                    stringToMenu "CurrentHp" = CurrentHp
                                    stringToMenu "CurrentDmg" = CurrentDmg
                                    stringToMenu "DmgMod" = DmgMod
                                    stringToMenu "HpMod" = HpMod
                                    stringToMenu "GameOver" = GameOver
                                    stringToMenu "MoveQuestion" = MoveQuestion
                                    stringToMenu "MoveNorth" = MoveN
                                    stringToMenu "MoveSouth" = MoveS
                                    stringToMenu "MoveEast" = MoveE
                                    stringToMenu "MoveWest" = MoveW
                                    stringToMenu "Stats" = Stats 
                                    stringToMenu "ActionPrompt" = ActionPrompt
                                    stringToMenu "Grab" = Grab
                                    stringToMenu "Drop" = Drop
                                    stringToMenu "FightPrompt" = FightPrompt
                                    stringToMenu "Fight" = Fight
                                    stringToMenu "Escape" = Escape
                                    stringToMenu _ = undefined -- Para calmar al linter 
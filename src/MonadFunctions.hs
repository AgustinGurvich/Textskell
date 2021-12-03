module MonadFunctions where

import AST
import GameBuilder
import System.IO
import System.Console.ANSI
import Control.Monad.State
import Data.Map.Strict as M 
import Data.Maybe

type GameState a = StateT (VarEnv, MapEnv, Player) IO a

getVars :: GameState VarEnv
getVars = do (v,_,_) <- get
             return v

getMap :: GameState MapEnv
getMap = do (_,m,_) <- get
            return m

getPlayer :: GameState Player
getPlayer = do (_,_,p) <- get
               return p

getMapSize :: GameState (Int,Int) 
getMapSize = do (v,m,p) <-  get
                let (CMapSize x y) = fromJust $ M.lookup (-1,-1) m
                return (x,y)

getAtom :: String -> GameState Atom
getAtom p = do (v,_,_) <-  get
               return $ fromJust $ M.lookup p v

getCell :: (Int,Int) -> GameState Cell
getCell p = do (_,m,_) <-  get
               return $ fromJust $ M.lookup p m

getPos :: GameState (Int,Int)
getPos = do (Player _ _ xPos yPos) <- getPlayer
            return (xPos,yPos)

updateVars :: VarEnv -> GameState ()
updateVars v = do (_,m,p) <- get
                  put (v,m,p)

updateMap :: MapEnv -> GameState ()
updateMap m = do (v,_,p) <- get
                 put (v,m,p)

updatePlayer :: Player -> GameState ()
updatePlayer p = do (v,m,_) <- get
                    put (v,m,p)

updateCell :: (Int,Int) -> Cell -> GameState ()
updateCell pos cell = do m <- getMap
                         let m' = M.insert pos cell m
                         updateMap m'

updatePos :: (Int,Int) -> GameState ()
updatePos (x,y) = do (Player hp dmg _ _) <-getPlayer
                     updatePlayer $ Player hp dmg x y

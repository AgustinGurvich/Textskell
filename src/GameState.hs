module GameState where

import AST
import GameBuilder
import System.IO
import System.Console.ANSI
import Control.Monad.State
import Data.Map.Strict as M 
import Data.Maybe

type GameState a = StateT (VarEnv, MapEnv, Player, MenuEnv) IO a

getVars :: GameState VarEnv
getVars = do (v,_,_,_) <- get
             return v

getMap :: GameState MapEnv
getMap = do (_,m,_,_) <- get
            return m

getPlayer :: GameState Player
getPlayer = do (_,_,p,_) <- get
               return p
getMenu :: GameState MenuEnv
getMenu = do (_,_,_,c) <- get
             return c

getMapSize :: GameState (Int,Int) 
getMapSize = do (_,m,_,_) <-  get
                let (CMapSize x y) = fromJust $ M.lookup (-1,-1) m
                return (x,y)

getAtom :: String -> GameState Atom
getAtom p = do (v,_,_,_) <-  get
               return $ fromJust $ M.lookup p v

getCell :: (Int,Int) -> GameState Cell
getCell p = do (_,m,_,_) <-  get
               return $ fromJust $ M.lookup p m

getMenuOpt :: Menu -> GameState String
getMenuOpt p = do (_,_,_,c) <-  get
                  return $ fromJust $ M.lookup p c

getPos :: GameState (Int,Int)
getPos = do (Player _ _ pos) <- getPlayer
            return pos

getMovementOpt :: GameState (String,String,String,String,String,String)
getMovementOpt = do moveQ <- getMenuOpt MoveQuestion
                    moveN <- getMenuOpt MoveN
                    moveS <- getMenuOpt MoveS
                    moveE <- getMenuOpt MoveE
                    moveW <- getMenuOpt MoveW
                    stats <- getMenuOpt Stats
                    return (moveQ,moveN,moveS,moveE,moveW,stats)

getActionOpt :: GameState (String,String,String)
getActionOpt = do prompt <- getMenuOpt ActionPrompt
                  grab <- getMenuOpt Grab
                  drop <- getMenuOpt Drop
                  return (prompt,grab,drop)

getFightOpt :: GameState (String,String,String)
getFightOpt = do prompt <- getMenuOpt FightPrompt
                 fight <- getMenuOpt Fight
                 escape <- getMenuOpt Escape
                 return (prompt,fight,escape)

updateVars :: VarEnv -> GameState ()
updateVars v = do (_,m,p,c) <- get
                  put (v,m,p,c)

updateMap :: MapEnv -> GameState ()
updateMap m = do (v,_,p,c) <- get
                 put (v,m,p,c)

updatePlayer :: Player -> GameState ()
updatePlayer p = do (v,m,_,c) <- get
                    put (v,m,p,c)

updateMenu :: MenuEnv -> GameState ()
updateMenu c = do (v,m,p,_) <- get
                  put (v,m,p,c)

updateCell :: (Int,Int) -> Cell -> GameState ()
updateCell pos cell = do m <- getMap
                         let m' = M.insert pos cell m
                         updateMap m'

updatePos :: (Int,Int) -> GameState ()
updatePos pos = do (Player hp dmg _) <-getPlayer
                   updatePlayer $ Player hp dmg pos

updateMenuOpt :: Menu -> String -> GameState ()
updateMenuOpt m str = do c <- getMenu
                         let c' = M.insert m str c
                         updateMenu c'
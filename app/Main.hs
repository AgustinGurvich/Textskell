module Main where

import Parser
import Lib
import AST
import System.Environment (getArgs)
import GameBuilder
import MapUtil
import GameState
import PPrint
import Data.Map.Strict as M
import Data.Maybe
import Data.Char

import Control.Concurrent(threadDelay)
import System.IO
import System.Exit
import System.Console.ANSI
import Control.Monad.State

errorHandler :: Error -> String
errorHandler (UndefVar s) = "Variable no definida: " ++ s
errorHandler (UndefCell s) = "Celda no definida: " ++ show s
errorHandler (InvalidPos s)  = "Posicion invalida: " ++ show s
errorHandler (TypeError s) = "Error de tipo: " ++ s
errorHandler (InvalidValue s) = "Valor invalido: " ++ s
errorHandler (UndefMenu s) = "Opcion de menu invalida: " ++ show s

pause :: Int -> IO ()
pause n = do hFlush stdout
             threadDelay (n * 1000000)

main :: IO ()
main = do args <- getArgs
          contents <- readFile $ head args
          let [opt] = tail args 
          let casoCoordenadas = takeWhile (/= '\n') contents -- Saco la linea que tiene el tamaño del mapa
          let limits = parseMap casoCoordenadas              -- Obtengo el tamaño del mapa de una forma poco elegante
          let evaluado = eval limits $ parse $ lexer contents
          case evaluado of
              Left e -> putStrLn ("Error: " ++ errorHandler e)
              Right (v,m,p,c) -> if M.size c == 28 then do case opt of
                                                            "play" -> do let m' = addJump m
                                                                         runStateT startGame (v,m',p,c)
                                                                         return ()
                                                            "pretty" -> prettyPrint v m p c
                                                   else putStrLn "Error: Menu incompleto"
  where parseMap s = let sacarPrimero = dropWhile (not . isDigit) s
                         primerNumero = takeWhile (/= ',') sacarPrimero
                         sacarSegundo = Prelude.drop 1 $ dropWhile (/= ',') s
                         segundoNumero = takeWhile (/= ')') sacarSegundo
                     in (read primerNumero, read segundoNumero)


prettyPrint :: VarEnv -> MapEnv -> Player -> MenuEnv -> IO ()
prettyPrint v m p c = do putStrLn $ ppPrompt "VARIABLES DEFINIDAS"
                         mapM_ (putStrLn . ppAtom) (M.toList v) >> putStrLn ""
                         putStrLn $ ppPrompt "CELDAS DEFINIDAS"
                         mapM_ (putStrLn . ppMap) (M.toList m) >> putStrLn ""
                         putStrLn $ ppPrompt "MENU DEFINIDO"
                         mapM_ (putStrLn . ppMenu) (M.toList c) >> putStrLn ""
                         putStrLn $ ppPrompt "JUGADOR DEFINIDO"
                         (putStrLn $ ppPlayer p) >> putStrLn ""
                         return ()

replaceStr :: Char -> String -> String -> String
replaceStr w s [] = []
replaceStr w s (x:xs) = if w == x then s++xs else  x : replaceStr w s xs

intro :: String
intro = "Juego hecho en Textskell, TP realizado para la materia Analisis de Lenguajes de Programacion. Version 1.0"

startGame :: GameState ()
startGame = do liftIO $ putStrLn intro
               title <- getMenuOpt Title
               liftIO $ putStrLn title
               gameLoop True

movements :: GameState ()
movements = do (moveQ,moveN,moveS,moveE,moveW,stats) <- getMovementOpt
               liftIO (putStrLn moveQ >> putStrLn ("1) " ++ moveN) >>  putStrLn ("2) " ++ moveS) >> putStrLn ("3) " ++ moveE) >> putStrLn ("4) " ++ moveW) >> putStrLn ("5) " ++ stats))

move :: GameState ()
move  = do movements
           (Player hp dmg xPos yPos) <- getPlayer
           bound <- getMapSize
           opt <- liftIO getLine
           invalidMovement <- getMenuOpt InvalidMovement
           case opt of
             "1" -> if outOfBounds (xPos-1, yPos) bound then (liftIO . putStrLn) invalidMovement >> move else do cell <- getCell (xPos-1, yPos)
                                                                                                                 case cell of
                                                                                                                      CClosed -> (liftIO . putStrLn) invalidMovement >> move
                                                                                                                      _ -> updatePos (xPos-1, yPos)
             "2" -> if outOfBounds (xPos+1, yPos) bound then (liftIO . putStrLn) invalidMovement >> move else do cell <- getCell (xPos+1, yPos)
                                                                                                                 case cell of
                                                                                                                   CClosed -> (liftIO . putStrLn) invalidMovement >> move
                                                                                                                   _ -> updatePos (xPos+1, yPos)
             "3" -> if outOfBounds (xPos, yPos+1) bound then (liftIO . putStrLn) invalidMovement >> move else do cell <- getCell (xPos, yPos+1)
                                                                                                                 case cell of
                                                                                                                   CClosed -> (liftIO . putStrLn) invalidMovement >> move
                                                                                                                   _ -> updatePos (xPos, yPos+1)
             "4" -> if outOfBounds (xPos, yPos-1) bound then (liftIO . putStrLn) invalidMovement >> move else do cell <- getCell (xPos, yPos-1)
                                                                                                                 case cell of
                                                                                                                   CClosed -> (liftIO . putStrLn) invalidMovement >> move
                                                                                                                   _ -> updatePos (xPos, yPos-1)
             "5" -> do hpPrompt <- getMenuOpt CurrentHp
                       (liftIO . putStrLn) (replaceStr '*' (show hp) hpPrompt)
                       dmgPrompt <- getMenuOpt CurrentDmg
                       (liftIO . putStrLn) (replaceStr '*' (show dmg) dmgPrompt)
                       move
             _ -> getMenuOpt InvalidOption >>= (liftIO . putStrLn) >> move


grabOrDrop :: GameState ()
grabOrDrop = do (prompt,grab,drop) <- getActionOpt
                liftIO (putStrLn prompt >> putStrLn ("1) " ++ grab) >> putStrLn ("2) " ++ drop))

fightOrFlight :: GameState ()
fightOrFlight = do (prompt,fight,escape) <- getFightOpt
                   liftIO (putStrLn prompt >> putStrLn ("1) " ++ fight) >> putStrLn ("2) " ++escape))

loopOpt :: GameState () -> GameState Bool
loopOpt action = do action
                    opt <- liftIO getLine
                    case opt of
                      "1" -> return True
                      "2" -> return False
                      _ -> getMenuOpt InvalidOption >>= (liftIO . putStrLn) >> loopOpt action

fightSimulation :: Player -> Atom -> Int -> GameState ()
fightSimulation p@(Player pHp pDmg xPos yPos) e@(Npc eHp eDmg) 0 = do let eHp' = eHp - pDmg
                                                                      hpPrompt <- getMenuOpt EnemyHp
                                                                      liftIO $ putStrLn $ replaceStr '*' (show (max eHp' 0)) hpPrompt
                                                                      liftIO $ pause 3
                                                                      if eHp' <= 0 then fightSimulation p e 1
                                                                                   else do let pHp' = pHp - eDmg
                                                                                           hpPrompt <- getMenuOpt CurrentHp
                                                                                           liftIO $ putStrLn $ replaceStr '*' (show (max pHp' 0)) hpPrompt
                                                                                           liftIO $ pause 3
                                                                                           if pHp' <= 0 then fightSimulation p e 2
                                                                                                        else fightSimulation (Player pHp' pDmg xPos yPos) (Npc eHp' eDmg) 0
-- Gano
fightSimulation p@(Player pHp pDmg xPos yPos) e@(Npc eHp eDmg) 1 = do victory <- getMenuOpt FightVictoryMsg
                                                                      liftIO $ putStrLn victory
                                                                      updatePlayer p
                                                                      updateCell (xPos, yPos) CEmpty
                                                                      return ()
-- Murio                                                              
fightSimulation p@(Player pHp pDmg xPos yPos) e@(Npc eHp eDmg) 2 = getMenuOpt DeathMsg >>= (liftIO . putStrLn) >> gameLoop False
fightSimulation _ _ _= undefined

handleEvent :: Cell -> GameState ()
handleEvent CEmpty = getMenuOpt EmptyCellMsg >>= (liftIO . putStrLn)
handleEvent (CTreasure (Item lore buff value) str) = do liftIO $ putStrLn str
                                                        grab <- loopOpt grabOrDrop
                                                        (v,m,p,c) <-  get
                                                        if grab then do liftIO $ putStrLn lore
                                                                        let (Player hp dmg xPos yPos) = p
                                                                        case buff of
                                                                          Dmg -> do dmgPrompt <- getMenuOpt DmgMod
                                                                                    liftIO $ putStrLn $ replaceStr '*' (show dmg) dmgPrompt
                                                                                    updatePlayer (Player hp (dmg+value) xPos yPos)
                                                                          HP -> do  hpPrompt <- getMenuOpt HpMod
                                                                                    liftIO $ putStrLn $ replaceStr '*' (show hp) hpPrompt
                                                                                    updatePlayer (Player (hp+value) dmg xPos yPos)
                                                                        updateCell (xPos, yPos) CEmpty
                                                                else do pos <- getPos
                                                                        updateCell pos CEmpty
                                                                        return ()
handleEvent (CEnemy enemy@(Npc hp dmg) str) =  do liftIO $ putStrLn str
                                                  hpPrompt <- getMenuOpt EnemyHp
                                                  dmgPrompt <- getMenuOpt EnemyDmg
                                                  liftIO $ putStrLn $ replaceStr '*' (show hp) hpPrompt
                                                  liftIO $ putStrLn $ replaceStr '*' (show dmg) dmgPrompt
                                                  fight <- loopOpt fightOrFlight
                                                  (v,m,p,c) <-  get
                                                  if fight then fightSimulation p enemy 0
                                                           else getMenuOpt RunAway >>= void . liftIO . putStrLn
handleEvent CExit = getMenuOpt ExitMsg >>=  (liftIO . putStrLn) >> gameLoop False
handleEvent (CMapSize _ _) = do liftIO $ putStrLn "No deberias estar aqui"
handleEvent CNewLine =  do liftIO $ putStrLn "No deberias estar aqui"
handleEvent CClosed =  do liftIO $ putStrLn "No deberias estar aqui"
handleEvent _ = undefined -- pa calmar al linter

gameLoop :: Bool -> GameState ()
gameLoop True = do (v,m,p,c) <- get
                   let (Player hp dmg xPos yPos) = p
                   posMsg <- getMenuOpt CurrentPos
                   liftIO $ putStrLn (posMsg ++ show (xPos,yPos))
                   liftIO $ printMap m p
                  --  liftIO $ print $ M.toList m
                   event <- getCell (xPos,yPos)
                   handleEvent event
                   move
                   gameLoop True
gameLoop False = getMenuOpt GameOver >>= (liftIO.putStrLn) >> liftIO exitSuccess




module Main where

import Parser
import Lib
import AST
import System.Environment (getArgs)
import GameBuilder
import MapUtil
import MonadFunctions
import Data.Map.Strict as M
import Data.Maybe

import Control.Concurrent(threadDelay)
import System.IO
import System.Exit
import System.Console.ANSI
import Control.Monad.State

errorHandler :: Error -> String
errorHandler UndefVar = "Variable no definida"
errorHandler UndefCell = "Celda no definida"
errorHandler InvalidPos  = "Posicion invalida"
errorHandler TypeError = "Error de tipo"
errorHandler InvalidValue = "Valor invalido"

pause :: Int -> IO ()
pause n = do hFlush stdout
             threadDelay (n * 1000000)

main :: IO ()
main = do args <- getArgs
          contents <- readFile $ head args
          let evaluado = eval $ parse $ lexer contents
          case evaluado of
              Left e -> putStrLn ("Error: " ++ errorHandler e)
              Right (v,m,p) -> do let m' = addJump m
                                  runStateT startGame (v,m',p)
                                  return ()

intro :: String
intro = "Juego hecho en Textskell, TP realizado para la materia Analisis de Lenguajes de Programacion. Version 1.0"

startGame :: GameState ()
startGame = do liftIO $ putStrLn intro
               gameLoop True

movements :: IO ()
movements = do putStrLn "¿Hacia donde ir?"
               putStrLn "1) Norte"
               putStrLn "2) Sur"
               putStrLn "3) Este"
               putStrLn "4) Oeste"
               putStrLn "5) Estadisticas de personaje"

move :: GameState ()
move  = do liftIO $ movements
           (Player hp dmg xPos yPos) <- getPlayer
           bound <- getMapSize
           opt <- liftIO getLine
           case opt of
             "1" -> if outOfBounds (xPos-1, yPos) bound then (liftIO . putStrLn) "Error: Movimiento invalido" >> move else updatePos (xPos-1, yPos)
             "2" -> if outOfBounds (xPos+1, yPos) bound then (liftIO . putStrLn) "Error: Movimiento invalido" >> move else updatePos (xPos+1, yPos)
             "3" -> if outOfBounds (xPos, yPos+1) bound then (liftIO . putStrLn) "Error: Movimiento invalido" >> move else updatePos (xPos, yPos+1)
             "4" -> if outOfBounds (xPos, yPos-1) bound then (liftIO . putStrLn) "Error: Movimiento invalido" >> move else updatePos (xPos, yPos-1)
             "5" -> (liftIO . putStrLn) ("Vida: " ++ show hp) >> (liftIO . putStrLn) ("Daño: " ++ show dmg) >> move
             _ -> (liftIO . putStrLn) "Error: Opcion invalida" >> move

grabOrDrop :: IO ()
grabOrDrop = do putStrLn "¿Que deseas hacer?"
                putStrLn "1) Agarrar"
                putStrLn "2) Ignorar"

fightOrFlight :: IO ()
fightOrFlight = do putStrLn "¿Que deseas hacer?"
                   putStrLn "1) Pelear"
                   putStrLn "2) Huir"

loopOpt :: IO () -> IO Bool
loopOpt action = do liftIO action
                    opt <- liftIO getLine
                    case opt of
                      "1" -> return True
                      "2" -> return False
                      _ -> (liftIO . putStrLn) "Error: Opcion invalida" >> loopOpt action

fightSimulation :: Player -> Atom -> Int -> GameState ()
fightSimulation p@(Player pHp pDmg xPos yPos) e@(Npc eHp eDmg) 0 = do let eHp' = eHp - pDmg
                                                                      liftIO $ putStrLn $ "Vida enemigo: " ++ show (max eHp' 0)
                                                                      liftIO $ pause 3
                                                                      if eHp' <= 0 then fightSimulation p e 1
                                                                                   else do let pHp' = pHp - eDmg
                                                                                           liftIO $ putStrLn $ "Vida actual: " ++ show (max pHp' 0)
                                                                                           liftIO $ pause 3
                                                                                           if pHp' <= 0 then fightSimulation p e 2
                                                                                                        else fightSimulation (Player pHp' pDmg xPos yPos) (Npc eHp' eDmg) 0
-- Gano
fightSimulation p@(Player pHp pDmg xPos yPos) e@(Npc eHp eDmg) 1 = do liftIO $ putStrLn "Venciste al enemigo" 
                                                                      updatePlayer p
                                                                      updateCell (xPos, yPos) CEmpty
                                                                      return ()
-- Murio                                                              
fightSimulation p@(Player pHp pDmg xPos yPos) e@(Npc eHp eDmg) 2 = liftIO (putStrLn "Moriste") >> gameLoop False
fightSimulation _ _ _= undefined

handleEvent :: Cell -> GameState ()
handleEvent CEmpty = do liftIO $ putStrLn "Nada que ver aqui"
handleEvent (CTreasure (Item lore buff value) str) = do liftIO $ putStrLn str
                                                        grab <- liftIO $ loopOpt grabOrDrop
                                                        (v,m,p) <-  get
                                                        if grab then do liftIO $ putStrLn lore
                                                                        let (Player hp dmg xPos yPos) = p
                                                                        case buff of
                                                                          Dmg -> do liftIO $ putStrLn $ "Aumento de daño: " ++ show value
                                                                                    updatePlayer (Player hp (dmg+value) xPos yPos)
                                                                          HP -> do  liftIO $ putStrLn $ "Aumento de salud: " ++ show value
                                                                                    updatePlayer (Player (hp+value) dmg xPos yPos)
                                                                        updateCell (xPos, yPos) CEmpty
                                                                else do pos <- getPos
                                                                        updateCell pos CEmpty
                                                                        return ()
handleEvent (CEnemy enemy@(Npc hp dmg) str) =  do liftIO $ putStrLn str
                                                  liftIO $ putStrLn $ "Salud enemigo: " ++ show hp
                                                  liftIO $ putStrLn $ "Daño enemigo: " ++ show dmg
                                                  fight <- liftIO $ loopOpt fightOrFlight
                                                  (v,m,p) <-  get
                                                  if fight then fightSimulation p enemy 0
                                                           else void (liftIO (putStrLn "Escapaste de la pelea"))
handleEvent CExit = do liftIO (putStrLn "Llegaste a la salida!") >> gameLoop False
handleEvent (CMapSize _ _) = do liftIO $ putStrLn "No deberias estar aqui"
handleEvent CNewLine =  do liftIO $ putStrLn "No deberias estar aqui"

gameLoop :: Bool -> GameState ()
gameLoop True = do (v,m,p) <- get
                   let (Player hp dmg xPos yPos) = p
                   liftIO $ putStrLn ("Posicion Actual: " ++ show (xPos,yPos))
                   liftIO $ printMap m p
                  --  liftIO $ print $ M.toList m
                   event <- getCell (xPos,yPos)
                   handleEvent event
                   move
                   gameLoop True
gameLoop False = liftIO (putStrLn "Fin del Juego") >> liftIO exitSuccess




module Main where

import Parser
import AST
import System.Environment (getArgs)
import GameBuilder
import MapUtil
import GameState
import PPrint
import Data.Map.Strict as M ( size, toList )
import Data.Maybe
import Data.List as L ( map, (\\), isSuffixOf )
import Data.Char ( isDigit )

import Control.Concurrent(threadDelay)
import System.IO ( stdout, hFlush )
import System.Exit ( exitSuccess )
import System.Console.ANSI
import Control.Monad.State

menus :: [Menu]
menus = [Title,InvalidMovement,Death,EmptyCell,Exit,FightVictory,CurrentPos,EnemyHp,EnemyDmg,RunAway,InvalidOption,CurrentHp,CurrentDmg,HpMod,DmgMod,GameOver,MoveQuestion,MoveN,MoveS,MoveE,MoveW,Stats,ActionPrompt,Grab,Drop,FightPrompt,Fight,Escape]

pause :: Int -> IO ()
pause n = do hFlush stdout
             threadDelay (n * 1000000)

main :: IO ()
main = do args <- getArgs
          let filename = head args
          if isSuffixOf ".txs" filename
            then do contents <- readFile filename
                    let [opt] = let arg = tail args in if arg == [] then [""] else arg
                    let casoCoordenadas = takeWhile (/= '\n') contents -- Saco la linea que tiene el tamaño del mapa
                    let limits = parseMap casoCoordenadas              -- Obtengo el tamaño del mapa 
                    let parseado = parse $ lexer contents
                    case parseado of
                      Ok parsedFile -> do let evaluado = eval limits parsedFile
                                          case evaluado of
                                            Left e -> putStrLn $ ppError e
                                            Right (v,m,p,c) -> do case opt of
                                                                    "-p" ->if M.size c == 28 then do let m' = addJump m
                                                                                                     runStateT startGame (v,m',p,c)
                                                                                                     return ()
                                                                                             else mapM_ ((putStrLn.ppError) . IncompleteMenu) (menus L.\\ L.map fst (M.toList c))
                                                                    "-l" -> logGame v m p c
                                                                    "-m" -> do let m' = addJump m
                                                                               liftIO $ printMap m' p
                                                                    _ ->  putStrLn $ ppError $ InvalidArgument opt

                      Failed s -> putStrLn s
            else putStrLn $ ppError $ InvalidArgument filename
  where parseMap s = let sacarPrimero = dropWhile (not . isDigit) s
                         primerNumero = takeWhile (/= ',') sacarPrimero
                         sacarSegundo = Prelude.drop 1 $ dropWhile (/= ',') s
                         segundoNumero = takeWhile (/= ')') sacarSegundo
                     in (read primerNumero, read segundoNumero)


logGame :: VarEnv -> MapEnv -> Player -> MenuEnv -> IO ()
logGame v m p c = do putStrLn $ ppPrompt "VARIABLES DEFINIDAS"
                     mapM_ (putStrLn . ppAtom) (M.toList v) >> putStrLn ""
                     putStrLn $ ppPrompt "CELDAS DEFINIDAS"
                     mapM_ (putStrLn . ppMap) (M.toList m) >> putStrLn ""
                     putStrLn $ ppPrompt "MENU DEFINIDO"
                     mapM_ (putStrLn . ppMenu) (M.toList c) >> putStrLn ""
                     putStrLn $ ppPrompt "JUGADOR DEFINIDO"
                     putStrLn (ppPlayer p) >> putStrLn ""
                     return ()

replaceStr :: Char -> String -> String -> String
replaceStr w s [] = []
replaceStr w s (x:xs) = if w == x then s++xs else  x : replaceStr w s xs

intro :: String
intro = "Juego hecho en Textskell, TP realizado para la materia Análisis de Lenguajes de Programación."

startGame :: GameState ()
startGame = do liftIO $ putStrLn intro
               liftIO $ putStrLn ""
               title <- getMenuOpt Title
               liftIO $ putStrLn title
               liftIO $ putStrLn ""
               gameLoop True

movements :: GameState ()
movements = do (moveQ,moveN,moveS,moveE,moveW,stats) <- getMovementOpt
               liftIO (putStrLn moveQ >> putStrLn ("1) " ++ moveN) >>  putStrLn ("2) " ++ moveS) >> putStrLn ("3) " ++ moveE) >> putStrLn ("4) " ++ moveW) >> putStrLn ("5) " ++ stats ) >> putStrLn "")

move :: GameState ()
move  = do movements
           (Player hp dmg (xPos, yPos)) <- getPlayer
           bound <- getMapSize
           liftIO $ putStrLn $ ppPrompt "> "
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
                       liftIO $ putStrLn ""
                       move
             _ -> getMenuOpt InvalidOption >>= (liftIO . putStrLn) >> move


grabOrDrop :: GameState ()
grabOrDrop = do (prompt,grab,drop) <- getActionOpt
                liftIO (putStrLn prompt >> putStrLn ("1) " ++ grab) >> putStrLn ("2) " ++ drop) >> putStrLn "")
                liftIO $ putStrLn $ ppPrompt "> "

fightOrFlight :: GameState ()
fightOrFlight = do (prompt,fight,escape) <- getFightOpt
                   liftIO (putStrLn prompt >> putStrLn ("1) " ++ fight) >> putStrLn ("2) " ++ escape) >> putStrLn "")
                   liftIO $ putStrLn $ ppPrompt "> "

loopOpt :: GameState () -> GameState Bool
loopOpt action = do action
                    opt <- liftIO getLine
                    case opt of
                      "1" -> return True
                      "2" -> return False
                      _ -> getMenuOpt InvalidOption >>= (liftIO . putStrLn) >> loopOpt action

fightSimulation :: Player -> Atom -> Int -> GameState ()
fightSimulation p@(Player pHp pDmg pos) e@(Npc eHp eDmg) 0 = do let eHp' = eHp - pDmg
                                                                hpPrompt <- getMenuOpt EnemyHp
                                                                liftIO $ putStrLn $ replaceStr '*' (show (max eHp' 0)) hpPrompt
                                                                liftIO $ pause 3
                                                                if eHp' <= 0 then fightSimulation p e 1
                                                                             else do let pHp' = pHp - eDmg
                                                                                     hpPrompt <- getMenuOpt CurrentHp
                                                                                     liftIO $ putStrLn $ replaceStr '*' (show (max pHp' 0)) hpPrompt
                                                                                     liftIO $ putStrLn ""
                                                                                     liftIO $ pause 3
                                                                                     if pHp' <= 0 then fightSimulation p e 2
                                                                                                  else fightSimulation (Player pHp' pDmg pos) (Npc eHp' eDmg) 0
-- Gano
fightSimulation p@(Player _ _ pos) _ 1 = do victory <- getMenuOpt FightVictory
                                            liftIO $ putStrLn victory
                                            updatePlayer p
                                            updateCell pos CEmpty
                                            return ()
-- Murio                                                              
fightSimulation _ _ 2 = getMenuOpt Death >>= (liftIO . putStrLn) >> gameLoop False
fightSimulation _ _ _= undefined

handleEvent :: Cell -> GameState ()
handleEvent CEmpty = getMenuOpt EmptyCell >>= (liftIO . putStrLn)
handleEvent (CTreasure (Item lore buff value) str) = do liftIO $ putStrLn str
                                                        grab <- loopOpt grabOrDrop
                                                        (v,m,p,c) <-  get
                                                        if grab then do liftIO $ putStrLn lore
                                                                        let (Player hp dmg pos) = p
                                                                        case buff of
                                                                          Dmg -> do dmgPrompt <- getMenuOpt DmgMod
                                                                                    dmgCurrent <- getMenuOpt CurrentDmg
                                                                                    let newDmg = dmg+value
                                                                                    liftIO $ putStrLn $ replaceStr '*' (show value) dmgPrompt
                                                                                    liftIO $ putStrLn $ replaceStr '*' (show newDmg) dmgCurrent
                                                                                    updatePlayer (Player hp newDmg pos)
                                                                          HP -> do  hpPrompt <- getMenuOpt HpMod
                                                                                    hpCurrent <- getMenuOpt CurrentHp
                                                                                    let newHp = hp+value
                                                                                    liftIO $ putStrLn $ replaceStr '*' (show value) hpPrompt
                                                                                    liftIO $ putStrLn $ replaceStr '*' (show $ max 0 newHp) hpCurrent
                                                                                    if newHp < 1 then getMenuOpt Death >>= (liftIO . putStrLn) >> gameLoop False else updatePlayer (Player newHp dmg pos)
                                                                        updateCell pos CEmpty
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
handleEvent CExit = getMenuOpt Exit >>=  (liftIO . putStrLn) >> gameLoop False
handleEvent (CMapSize _ _) = do liftIO $ putStrLn "No deberias estar aqui"
handleEvent CNewLine =  do liftIO $ putStrLn "No deberias estar aqui"
handleEvent CClosed =  do liftIO $ putStrLn "No deberias estar aqui"
handleEvent _ = undefined -- para calmar al linter

gameLoop :: Bool -> GameState ()
gameLoop True = do (v,m,p,c) <- get
                   let (Player hp dmg pos) = p
                   posMsg <- getMenuOpt CurrentPos
                   liftIO $ putStrLn (posMsg ++ show pos)
                   liftIO $ printMap m p
                   event <- getCell pos
                   handleEvent event
                   move
                   gameLoop True
gameLoop False = getMenuOpt GameOver >>= (liftIO.putStrLn) >> liftIO exitSuccess




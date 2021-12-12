module MapUtil where

import AST
import GameBuilder
import Data.Map.Strict as M
import Data.Maybe
import System.Console.ANSI

-- Le añade al mapa saltos de linea para una mejor impresion
addJump :: MapEnv -> MapEnv 
addJump m = let (CMapSize xbound ybound) = fromJust $ M.lookup(-1,-1) m  in addJump' m (xbound - 1) ybound   

addJump' :: MapEnv -> Int -> Int -> MapEnv
addJump' m 0 y = M.insert (0,y) CNewLine m
addJump' m x y = M.insert (x,y) CNewLine (addJump' m (x-1) y)

-- Imprime el mapa
printMap :: MapEnv -> Player -> IO ()
printMap m (Player _ _ x y) = putStrLn "" >> mapM_ (printCell (x,y)) (M.toList m) >> setSGR[Reset] >> putStrLn ""

-- Dada la posicion del jugador y una celda del mapa, lo imprime
printCell :: (Int,Int) -> ((Int,Int) , Cell) -> IO ()
printCell p@(xp,yp) ((xc,yc),c) = if xc == xp && yc == yp then setSGR [SetColor Foreground Dull Yellow] >> putStr "@" else cellSymbol c

cellSymbol :: Cell -> IO ()
cellSymbol CEmpty = setSGR[SetColor Foreground Dull White] >> putStr "x"
cellSymbol (CTreasure _ _) = setSGR[SetColor Foreground Dull Green] >> putStr "$" 
cellSymbol (CEnemy _ _) = setSGR[SetColor Foreground Dull Red] >> putStr "!" 
cellSymbol CClosed = putStr " "
cellSymbol CExit = setSGR[SetColor Foreground Dull Blue] >> putStr "O" 
cellSymbol (CMapSize _ _) =  putStr "" 
cellSymbol CNewLine = putStr "\n"

-- printEvent :: (Int,Int) -> MapEnv -> IO Cell
-- printEvent p@(xPos,yPos) m = do let cell = fromJust $ M.lookup p m 
--                                 case cell of
--                                     CEmpty -> putStrLn "Nada que ver aqui" 
--                                     (CTreasure a lore) -> putStrLn lore
--                                     (CEnemy a lore) -> putStrLn lore
--                                     (CExit) -> putStrLn "Salida"
--                                     _ -> putStrLn "Whoops no deberias estar aqui"
--                                 return cell 
module MapUtil where

import AST
import GameBuilder
import Data.Map.Strict as M
import Data.Maybe

addJump :: MapEnv -> MapEnv 
addJump m = let (CMapSize xbound ybound) = fromJust $ M.lookup(-1,-1) m  in addJump' m (xbound - 1) ybound   

addJump' :: MapEnv -> Int -> Int -> MapEnv
addJump' m 0 y = M.insert (0,y) CNewLine m
addJump' m x y = M.insert (x,y) CNewLine (addJump' m (x-1) y)

printMap :: MapEnv -> IO ()
printMap m = printCell (M.toList m)


printCell :: [((Int,Int) , Cell)] -> IO ()
printCell [] = putStrLn ""
printCell ((_,c):xs) = case c of
                        CEmpty -> putStr "x" >> printCell xs
                        CTreasure _ _ -> putStr "$" >> printCell xs
                        CEnemy _ _ -> putStr "+" >> printCell xs
                        CExit -> putStr "O" >> printCell xs
                        CMapSize _ _ -> putStr "" >> printCell xs
                        CNewLine -> putStr "\n" >> printCell xs
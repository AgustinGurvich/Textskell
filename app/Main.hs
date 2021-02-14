module Main where

import Parser 
import Lib
import AST
import System.Environment (getArgs)
import GameBuilder
import MapUtil

main :: IO ()
main = do args <- getArgs
          contents <- readFile $ head args
          let evaluado = eval $ parse $ lexer contents
          case evaluado of
              Left e -> print e
              Right (v,m,p) -> do let m' = addJump m
                                  printMap m'
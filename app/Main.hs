module Main where

import Parser 
import Lib
import AST
import System.Environment (getArgs)
import GameBuilder

main :: IO ()
main = do args <- getArgs
          contents <- readFile $ head args
          let evaluado = eval $ parse $ lexer contents
          print evaluado
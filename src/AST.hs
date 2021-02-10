module AST where

newtype C = Command Comm

data Comm = Assign String Atom
          | CreatePlayer Player
          | CreateCell Int Int Cell
          | CreateMap FilePath
            deriving (Show, Eq)

data Cell = CEmtpy
          | CTreasure
          | CEnemy
          | CExit
            deriving (Show, Eq)

data Atom = Npc Int Int 
          | Item String Buff Int
          | Var String
            deriving (Show, Eq)

data Player = Player Int Int Int Int deriving (Show, Eq)

data Buff = Dmg | HP deriving (Show, Eq) 

data Token =  TAss
            | TOpen
            | TClose
            | TComma
            | TPlayer
            | TCell
            | TMap
            | THp
            | TDmg
            | TInt Int
            | TVar String
            | TEmpty
            | TTreasure
            | TEnemy
            | TExit

{-
TO DO: Agregar la opcion de Lore y parsear ""
-}
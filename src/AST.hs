module AST where

data Comm = Assign String Atom
          | CreatePlayer Player
          | CreateCell Int Int Cell
          | SetMapSize Int Int
            deriving (Show, Eq)

data Cell = CEmpty
          | CTreasure Atom String
          | CEnemy Atom String
          | CExit
          | CMapSize Int Int
          | CNewLine
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
            | TQuote
            | TPlayer
            | TCell
            | THp
            | TDmg
            | TInt Int
            | TVar String
            | TLore String
            | TEmpty
            | TTreasure
            | TEnemy
            | TExit
            | TMapSize

data Error = UndefVar | UndefCell | InvalidPos | TypeError | InvalidValue deriving (Eq,Show)
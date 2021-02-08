module AST where

data C = Command Comm

data Comm = CreateNpc String Npc
          | CreateItem String Item
          | CreatePlayer Player
          | CreateCell Int Int Cell
          | CreateMap FilePath
            deriving (Show, Eq)

data Npc = Npc Int Int deriving (Show, Eq)

data Item = Item String Buff Int deriving (Show, Eq)

data Player = Player Int Int Pos deriving (Show, Eq)

data Pos = Pos Int Int deriving (Show, Eq)

data Buff = Dmg | HP deriving (Show, Eq) 

data StrList = Cons String StrList | Single String deriving (Show, Eq)

data LString = LString String deriving (Show, Eq)

data Var = VString String deriving (Show, Eq)

data File = File FilePath deriving (Show, Eq)

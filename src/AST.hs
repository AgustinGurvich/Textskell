module AST where

{-
  Comm son los comandos posibles:
  -Assign: Asignacion de variables
  -CreatePlayer: Crear el personaje jugable
  -CreateCell: Crear una celda del mapa
  -SetMapSize: Dar el tamañno del mapa 
-}
data Comm = Assign String Atom
          | CreatePlayer Player
          | CreateCell Int Int Cell
          | SetMapSize Int Int
            deriving (Show, Eq)

{-
  Cell son los posibles elementos de una celda del mapa:
  -CEmpty: No hay nada
  -CTreasure: El contenido del tesoro, junto a una descripcion
  -CTreasure: El enemigo, junto a una descripcion
  -CClosed: Celda cerrada
  -CExit: El objetivo final del juego
  -CMapSize: El tamaño del mapa, para acceder de forma rapida y hacer calculos
  -CNewLine: Para imprimir bien el mapa. TODO: ¿Se podria sacar?
-}
data Cell = CEmpty
          | CTreasure Atom String
          | CEnemy Atom String
          | CClosed
          | CExit
          | CMapSize Int Int
          | CNewLine
            deriving (Show, Eq)

{-
  Atom Son los posibles elementos del juego:
  -Npc es un enemigo que tiene ataque y salud
  -Item es un elemento que tiene una descripcio, un tipo de modificador y un valor que modifica
  -Var es una variable guardada en el entorno
-}
data Atom = Npc Int Int 
          | Item String Buff Int
          | Var String
            deriving (Show, Eq)

-- El jugador que tiene vida, daño, posX y posY
data Player = Player Int Int Int Int deriving (Show, Eq)

-- Las estadisticas que se pueden modificar
data Buff = Dmg | HP deriving (Show, Eq) 

-- Token para el parser
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
            | TClosed
            | TMapSize

-- Errores para la monada
data Error = UndefVar | UndefCell | InvalidPos | TypeError | InvalidValue deriving (Eq,Show)
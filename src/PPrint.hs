module PPrint where

import Data.Text (unpack)
import AST
import Prettyprinter
import Prettyprinter.Render.Terminal
  ( AnsiStyle,
    Color (..),
    bold,
    color,
    colorDull,
    italicized,
    renderStrict,
  )
import Prettyprinter (defaultLayoutOptions)

-- Funcion de renderizado
render :: Doc AnsiStyle -> String
render = unpack . renderStrict. layoutSmart defaultLayoutOptions

-- Pretty printer para Celdas

treasureColor = annotate (colorDull Green <> bold)

exitColor = annotate (colorDull Blue <> bold)

enemyColor = annotate (colorDull Red <> bold)

loreColor = annotate (colorDull White <> italicized)

blockedCellColor = annotate (colorDull Red)

treasure2Doc :: String -> Doc AnsiStyle
treasure2Doc str = treasureColor $ pretty str

enemy2Doc :: String -> Doc AnsiStyle
enemy2Doc str = enemyColor $ pretty str

lore2Doc :: String -> Doc AnsiStyle
lore2Doc str = loreColor $ pretty str

coord2Doc :: Int -> Int -> Doc AnsiStyle
coord2Doc x y = tupled [pretty x,pretty y]

exit2Doc :: String -> Doc AnsiStyle
exit2Doc str = exitColor $ pretty str

cell2Doc :: Cell -> Doc AnsiStyle
cell2Doc CEmpty =  pretty "Celda Vacia"
cell2Doc (CTreasure item lore) = treasure2Doc "Tesoro:" <> line <> indent 6 (atom2Doc item <> line <> pretty "Lore: " <> lore2Doc lore)
cell2Doc (CEnemy enemy lore) =  enemy2Doc "Enemigo:" <> line <> indent 6 (atom2Doc enemy <> line <> pretty "Lore: " <> lore2Doc lore)
cell2Doc CClosed =blockedCellColor $ pretty "Celda Inaccesible"
cell2Doc CExit = exit2Doc "Salida"
cell2Doc (CMapSize x y) = pretty "Tamaño del mapa: " <> coord2Doc x y
cell2Doc CNewLine = undefined

ppCell :: Cell -> String
ppCell = render . cell2Doc

map2Doc :: ((Int,Int),Cell) -> Doc AnsiStyle
map2Doc ((x,y),c) = coord2Doc x y <> pretty ":" <+> cell2Doc c

ppMap :: ((Int,Int),Cell) -> String
ppMap = render . map2Doc

-- Pretty printer para atomos

buffColor = annotate (color Blue <> italicized)

hpColor = annotate (color Green <> bold)

dmgColor = annotate (color Red <> bold)

varColor = annotate (color Yellow <> bold)

hp2Doc :: Int -> Doc AnsiStyle
hp2Doc hp = hpColor $ pretty hp

dmg2Doc :: Int -> Doc AnsiStyle
dmg2Doc dmg = dmgColor $ pretty dmg

buff2Doc :: String -> Doc AnsiStyle
buff2Doc buff = buffColor $ pretty buff

var2Doc :: String -> Doc AnsiStyle
var2Doc var = varColor $ pretty var

atom2Doc :: Atom -> Doc AnsiStyle
atom2Doc (Npc hp dmg) = pretty "Vida Enemigo:" <+> hp2Doc hp <> line <> pretty "Daño enemigo:" <+> dmg2Doc dmg
atom2Doc (Item lore Dmg value) = pretty "Objeto:" <+> lore2Doc lore <> line <> pretty "Buff: " <+> buff2Doc (show Dmg) <>line <> pretty "Valor" <+> dmg2Doc value
atom2Doc (Item lore HP value) = pretty "Objeto:" <+> lore2Doc lore <> line <> pretty "Buff: " <+> buff2Doc (show HP) <>line <> pretty "Valor" <+> hp2Doc value
atom2Doc (Var str) = pretty "Variable:" <+> pretty str

ppAtom :: (String,Atom) -> String
ppAtom (var,atom ) = render $ var2Doc var <> colon <> line <> indent 2 (atom2Doc atom)

-- Pretty printer para Player

playerColor = annotate (color Yellow)

player2Doc :: String -> Doc AnsiStyle
player2Doc str = playerColor $ pretty str

ppPlayer :: Player -> String
ppPlayer (Player hp dmg x y) = render $ player2Doc "Jugador" <> colon <> line <> indent 4 (pretty "Vida Jugador:" <+> hp2Doc hp <> line <> pretty "Daño Jugador:" <+> dmg2Doc dmg <> line <> pretty "Posicion Inicial:" <+> coord2Doc x y )

-- Pretty pritner para Menu

txtColor = annotate (colorDull White <> bold)
strColor = annotate (colorDull White <> italicized )

txt2Doc :: String -> Doc AnsiStyle
txt2Doc str = txtColor $ pretty str

str2Doc :: String -> Doc AnsiStyle
str2Doc str = strColor $ pretty str

menu2Doc :: Menu -> Doc AnsiStyle
menu2Doc menu = txt2Doc (show menu) 

ppMenu :: (Menu,String) -> String
ppMenu (menu,str) = render $  menu2Doc menu <> colon <+> str2Doc str 

promptColor = annotate (color Black <> bold)

ppPrompt :: String -> String
ppPrompt string = render $ promptColor $ pretty string


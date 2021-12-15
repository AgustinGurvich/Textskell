{
module Parser where
import AST 
import Data.Char
}

%name parse 
%tokentype { Token }
%error { parseError }


%token
  '<-'               {TAss}
  '('                {TOpen}
  ')'                {TClose}
  ','                {TComma}
  '"'                {TQuote}
  setPlayer          {TPlayer}
  setCell            {TCell}
  Dmg                {TDmg}
  HP                 {THp}
  Int                {TInt $$}
  Var                {TVar $$}
  Lore               {TLore $$}
  Empty              {TEmpty}
  Treasure           {TTreasure}
  Enemy              {TEnemy}
  Exit               {TExit} 
  Closed             {TClosed}
  mapSize            {TMapSize}
  setMenu            {TMenu}    




%%

start :: {[Comm]}
start : mapSize '(' Int ',' Int ')' Comms          {SetMapSize $3 $5 : $7}

Comms :: {[Comm]}
Comms : Comm                                       {[$1]}
      | Comm Comms                                 { $1 : $2 }

Comm :: {Comm}
Comm : Var '<-' Atom                             {Assign $1 $3}
     | setPlayer Player                          {CreatePlayer $2}
     | setCell '(' Int ',' Int ')' Cell          {CreateCell $3 $5 $7}
     | setMenu '(' Var ',' '"' Lore '"' ')'     {SetMenu $3 $6}
     
Cell :: {Cell}
Cell : Empty                                     {CEmpty} 
     | Treasure '(' Atom ',' '"' Lore '"' ')'    {CTreasure $3 $6}
     | Enemy '(' Atom ',' '"' Lore '"' ')'       {CEnemy $3 $6}     
     | Exit                                      {CExit}
     | Closed                                    {CClosed}
      
Atom :: {Atom}
Atom : '(' Int ',' Int ')'                         {Npc $2 $4} 
     | '(' '"' Lore '"' ',' Buff ',' Int ')'       {Item $3 $6 $8}
	| Var		                               {Var $1}			

Player :: {Player}
Player : '(' Int ',' Int ',' '(' Int ',' Int ')' ')'  {Player $2 $4 $7 $9}

Buff :: {Buff}
Buff : Dmg                                         {Dmg}
     |  HP                                         {HP}




{
parseError :: [Token] -> a
parseError _ = error "Parse error" 

lexer [] = []
lexer ('<':'-':cs) = TAss : lexer cs
lexer ('-':cs) = let ((TInt x):xs) = lexNum cs in (TInt (-x)) : xs    
lexer ('"' : cs) = let (str,(quote:rest)) = span (\x -> x /= '"') cs in TQuote : TLore str : TQuote : lexer rest 
lexer ('(' : cs) = TOpen : lexer cs
lexer (')' : cs) = TClose : lexer cs
lexer (',' : cs) = TComma : lexer cs
lexer (c:cs)  
          | isSpace c = lexer cs
          | isAlpha c = lexVar (c:cs)
          | isDigit c = lexNum (c:cs)

lexNum cs = TInt (read num) : lexer rest where
            (num, rest) = span isDigit cs

lexVar cs = case span isAlpha cs of 
          ("setPlayer",rest) -> TPlayer : lexer rest
          ("setCell", rest) -> TCell : lexer rest
          ("Hp", rest) -> THp : lexer rest
          ("Dmg", rest) -> TDmg : lexer rest
          ("Empty", rest) -> TEmpty : lexer rest
          ("Treasure", rest) -> TTreasure : lexer rest
          ("Enemy", rest) -> TEnemy : lexer rest
          ("Exit", rest) -> TExit : lexer rest
          ("Closed", rest) -> TClosed : lexer rest
          ("mapSize",rest) -> TMapSize : lexer rest
          ("setMenu", rest) -> TMenu : lexer rest
          (s,rest) -> TVar s : lexer rest 

-- TO DO: Parsear la extension del archivo 

}

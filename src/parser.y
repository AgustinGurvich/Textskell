{
module TextskellParse where
import AST 
import Data.Char
}

%name parse 
%tokentype { Token }
%error { parseError }


%token
  '<-'        {TAss}
  '('         {TOpen}
  ')'         {TClose}
  ','         {TComma}
  setPlayer   {TPlayer}
  setCell     {TCell}
  setMap      {TMap}
  Dmg         {TDmg}
  HP          {THp}
  Int         {TInt $$}
  Var         {TVar $$}
  Empty       {TEmpty}
  Treasure    {TTreasure}
  Enemy       {TEnemy}
  Exit        {TExit} 





%%




Comms : Comm                                       {[$1]}
      | Comm Comms                                 { $1 : $2 }

Comm : Var '<-' Atom                             {Assign $1 $2}
     | setPlayer Player                          {CreatePlayer $2}
     | setCell '(' Int ',' Int ')' Cell          {CreateCell $3 $5 $7}
     | setMap Var                                {CreateMap $2}

Cell : Empty                                     {CEmpty} 
     | Treasure '(' Atom ',' Atom ')'            {CTreasure $3 $5}
     | Enemy '(' Atom ',' Atom ')'               {CEnemy $3 $5}     
     | Exit                                      {CExit}

Atom : '(' Int ',' Int ')'                         {Npc $2 $4} 
     | '(' Atom ',' Buff ',' Int ')'               {Item $2 $4 $6}
	| Var		                               {Var $1}			

Player : '(' Int ',' Int ',' '(' Int ',' Int ')' ')'  {Player $2 $4 $7 $9}

Buff : Dmg                                         {Dmg}
     |  HP                                         {Hp}




{
lexer [] = []
lexer ('<':'-':cs) = TAss : lexer cs
lexer ('(' : cs) = TOpen : lexer cs
lexer (')' : cs) = TClose : lexer cs
lexer (',' : cs) = TComma : lexer cs
lexer (')' : cs) = TClose : lexer cs
lexer (c:cs)  
          | isSpace c = lexer cs
          | isAlpha c = lexVar (c:cs)
          | isDigit c = lexNum (c:cs)

lexNum cs = TInt (read num) : lexer rest where
            (num, rest) = span isDigit cs

lexVar cs = case span isAlpha cs of 
          ("setPlayer",rest) -> TPlayer : lexer rest
          ("setCell", rest) -> TCell : lexer rest
          ("setMap", rest) -> TMap : lexer rest
          ("Hp", rest) -> THp : lexer rest
          ("Dmg", rest) -> TDmg : lexer rest
          ("Empty", rest) -> TEmpty : lexer rest
          ("Treasure", rest) -> TTreasure : lexer rest
          ("TEnemy", rest) -> TEnemy : lexer rest
          ("TExit", rest) -> TExit : lexer rest
          (s,rest) -> TVar s : lexer rest 
}

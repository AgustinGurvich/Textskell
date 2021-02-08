{
module Parser where
import AST 
}

%name parse 
%tokentype { Token }
%error { parseError }

%token
  '<-'        {TAss}
  '('         {TOpen}
  ')'         {TClose}
  ','         {TComma}
  ';'         {TSemiColon}
  newNpc      {TNpc}
  newItem     {TItem}
  setPlayer   {TPlayer}
  setCell     {TCell}
  setMap      {TMap}
  Dmg         {TDmg}
  HP          {THp}





%%




C : Comm ';'                                       {Command $1}

Comm : 'newNPC' Var '<-' NPC                    {CreateNpc $2 $4}
     | 'newItem' Var '<-' Item                  {CreateItem $2 $4}
     | 'setPlayer' Player                          {CreatePlayer $2}
     | 'setCell' '(' Int ',' Int ')' Cell          {CreateCell $3 $5 $7}
     | 'setMap' File                               {CreateMap $2}


Cell : 'Empty'                                     {CEmpty} 
     | 'Treasure' '(' Atom ',' LString ')'          {CTreasure $3 $5}
     | 'Enemy' '(' Atom ',' LString ',' StrList ')'  {CEnemy $3 $5 $7}     
     | 'Exit'                                      {CExit}

Atom : '(' Int ',' Int ')'                         {Npc $2 $4} 
		 | '(' String ',' Buff ',' Int ')'             {Item $2 $4 $6}
		 | VString																		 {VString $1}			

Player : '(' Int ',' Int ',' Pos ')'               {Player $2 $4 $6}

Pos  : '(' Int ',' Int ')'                         {Pos $2 $4} 

Buff : Dmg                                         {Dmg}
     |  HP                                         {Hp}

Int : Int                                          {Int $1}

StrList : String ';' StrList                       {Cons $1 $3}
        | String                                   {Single $1}

LString : String                                   {LString $1}

Var : Var                                          {VString $1}

File :  File                                       {File $1}




{

parseError :: [Token] -> a
parseError _ = error "Parse Error"

data Token = TAss
					 | TOpen
					 | TClose
					 | TComma
					 | TSemiColon
					 | TNpc
					 | TItem
					 | TPlayer
					 | TCell
					 | TMap
					 | THp
					 | TDmg

}

{-# OPTIONS_GHC -w #-}
module TextskellParse where
import AST
    ( Token(..),
      Buff(Dmg),
      Player(Player),
      Atom(Var, Npc, Item),
      Cell(CExit, CTreasure, CEnemy),
      Comm(CreateMap, Assign, CreatePlayer, CreateCell) ) 
import Data.Char ( isDigit, isAlpha, isSpace )
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.20.0

data HappyAbsSyn t4 t5 t6 t7 t8 t9
	= HappyTerminal (Token)
	| HappyErrorToken Prelude.Int
	| HappyAbsSyn4 t4
	| HappyAbsSyn5 t5
	| HappyAbsSyn6 t6
	| HappyAbsSyn7 t7
	| HappyAbsSyn8 t8
	| HappyAbsSyn9 t9

happyExpList :: Happy_Data_Array.Array Prelude.Int Prelude.Int
happyExpList = Happy_Data_Array.listArray (0,77) ([57344,8,4544,0,0,32,16384,0,0,32769,0,0,0,2272,0,0,8208,0,0,16384,0,0,0,1,8,4096,0,0,4096,48,0,0,1,512,0,256,0,2,16,4096,0,4096,0,24,256,0,0,0,0,4,0,240,8,0,16,0,0,0,128,0,1,0,0,0,0,8,32,8192,64,32832,0,2,0,1,8,4096,0,0,4096,32,16416,32768,0,256,0,2,1024,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parse","Comms","Comm","Cell","Atom","Player","Buff","'<-'","'('","')'","','","setPlayer","setCell","setMap","Dmg","HP","Int","Var","Empty","Treasure","Enemy","Exit","%eof"]
        bit_start = st Prelude.* 25
        bit_end = (st Prelude.+ 1) Prelude.* 25
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..24]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

action_0 (14) = happyShift action_3
action_0 (15) = happyShift action_4
action_0 (16) = happyShift action_5
action_0 (20) = happyShift action_6
action_0 (4) = happyGoto action_7
action_0 (5) = happyGoto action_8
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (14) = happyShift action_3
action_1 (15) = happyShift action_4
action_1 (16) = happyShift action_5
action_1 (20) = happyShift action_6
action_1 (5) = happyGoto action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyFail (happyExpListPerState 2)

action_3 (11) = happyShift action_14
action_3 (8) = happyGoto action_13
action_3 _ = happyFail (happyExpListPerState 3)

action_4 (11) = happyShift action_12
action_4 _ = happyFail (happyExpListPerState 4)

action_5 (20) = happyShift action_11
action_5 _ = happyFail (happyExpListPerState 5)

action_6 (10) = happyShift action_10
action_6 _ = happyFail (happyExpListPerState 6)

action_7 (25) = happyAccept
action_7 _ = happyFail (happyExpListPerState 7)

action_8 (14) = happyShift action_3
action_8 (15) = happyShift action_4
action_8 (16) = happyShift action_5
action_8 (20) = happyShift action_6
action_8 (4) = happyGoto action_9
action_8 (5) = happyGoto action_8
action_8 _ = happyReduce_1

action_9 _ = happyReduce_2

action_10 (11) = happyShift action_18
action_10 (20) = happyShift action_19
action_10 (7) = happyGoto action_17
action_10 _ = happyFail (happyExpListPerState 10)

action_11 _ = happyReduce_6

action_12 (19) = happyShift action_16
action_12 _ = happyFail (happyExpListPerState 12)

action_13 _ = happyReduce_4

action_14 (19) = happyShift action_15
action_14 _ = happyFail (happyExpListPerState 14)

action_15 (13) = happyShift action_23
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (13) = happyShift action_22
action_16 _ = happyFail (happyExpListPerState 16)

action_17 _ = happyReduce_3

action_18 (11) = happyShift action_18
action_18 (19) = happyShift action_21
action_18 (20) = happyShift action_19
action_18 (7) = happyGoto action_20
action_18 _ = happyFail (happyExpListPerState 18)

action_19 _ = happyReduce_13

action_20 (13) = happyShift action_27
action_20 _ = happyFail (happyExpListPerState 20)

action_21 (13) = happyShift action_26
action_21 _ = happyFail (happyExpListPerState 21)

action_22 (19) = happyShift action_25
action_22 _ = happyFail (happyExpListPerState 22)

action_23 (19) = happyShift action_24
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (13) = happyShift action_33
action_24 _ = happyFail (happyExpListPerState 24)

action_25 (12) = happyShift action_32
action_25 _ = happyFail (happyExpListPerState 25)

action_26 (19) = happyShift action_31
action_26 _ = happyFail (happyExpListPerState 26)

action_27 (17) = happyShift action_29
action_27 (18) = happyShift action_30
action_27 (9) = happyGoto action_28
action_27 _ = happyFail (happyExpListPerState 27)

action_28 (13) = happyShift action_41
action_28 _ = happyFail (happyExpListPerState 28)

action_29 _ = happyReduce_15

action_30 _ = happyReduce_16

action_31 (12) = happyShift action_40
action_31 _ = happyFail (happyExpListPerState 31)

action_32 (21) = happyShift action_36
action_32 (22) = happyShift action_37
action_32 (23) = happyShift action_38
action_32 (24) = happyShift action_39
action_32 (6) = happyGoto action_35
action_32 _ = happyFail (happyExpListPerState 32)

action_33 (11) = happyShift action_34
action_33 _ = happyFail (happyExpListPerState 33)

action_34 (19) = happyShift action_45
action_34 _ = happyFail (happyExpListPerState 34)

action_35 _ = happyReduce_5

action_36 _ = happyReduce_7

action_37 (11) = happyShift action_44
action_37 _ = happyFail (happyExpListPerState 37)

action_38 (11) = happyShift action_43
action_38 _ = happyFail (happyExpListPerState 38)

action_39 _ = happyReduce_10

action_40 _ = happyReduce_11

action_41 (19) = happyShift action_42
action_41 _ = happyFail (happyExpListPerState 41)

action_42 (12) = happyShift action_49
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (11) = happyShift action_18
action_43 (20) = happyShift action_19
action_43 (7) = happyGoto action_48
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (11) = happyShift action_18
action_44 (20) = happyShift action_19
action_44 (7) = happyGoto action_47
action_44 _ = happyFail (happyExpListPerState 44)

action_45 (13) = happyShift action_46
action_45 _ = happyFail (happyExpListPerState 45)

action_46 (19) = happyShift action_52
action_46 _ = happyFail (happyExpListPerState 46)

action_47 (13) = happyShift action_51
action_47 _ = happyFail (happyExpListPerState 47)

action_48 (13) = happyShift action_50
action_48 _ = happyFail (happyExpListPerState 48)

action_49 _ = happyReduce_12

action_50 (11) = happyShift action_18
action_50 (20) = happyShift action_19
action_50 (7) = happyGoto action_55
action_50 _ = happyFail (happyExpListPerState 50)

action_51 (11) = happyShift action_18
action_51 (20) = happyShift action_19
action_51 (7) = happyGoto action_54
action_51 _ = happyFail (happyExpListPerState 51)

action_52 (12) = happyShift action_53
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (12) = happyShift action_58
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (12) = happyShift action_57
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (12) = happyShift action_56
action_55 _ = happyFail (happyExpListPerState 55)

action_56 _ = happyReduce_9

action_57 _ = happyReduce_8

action_58 _ = happyReduce_14

happyReduce_1 = happySpecReduce_1  4 happyReduction_1
happyReduction_1 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn4
		 ([happy_var_1]
	)
happyReduction_1 _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_2  4 happyReduction_2
happyReduction_2 (HappyAbsSyn4  happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn4
		 (happy_var_1 : happy_var_2
	)
happyReduction_2 _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_3  5 happyReduction_3
happyReduction_3 _
	(HappyTerminal happy_var_2)
	(HappyTerminal (TVar happy_var_1))
	 =  HappyAbsSyn5
		 (Assign happy_var_1 happy_var_2
	)
happyReduction_3 _ _ _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_2  5 happyReduction_4
happyReduction_4 (HappyAbsSyn8  happy_var_2)
	_
	 =  HappyAbsSyn5
		 (CreatePlayer happy_var_2
	)
happyReduction_4 _ _  = notHappyAtAll 

happyReduce_5 = happyReduce 7 5 happyReduction_5
happyReduction_5 ((HappyAbsSyn6  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TInt happy_var_5)) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TInt happy_var_3)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn5
		 (CreateCell happy_var_3 happy_var_5 happy_var_7
	) `HappyStk` happyRest

happyReduce_6 = happySpecReduce_2  5 happyReduction_6
happyReduction_6 (HappyTerminal (TVar happy_var_2))
	_
	 =  HappyAbsSyn5
		 (CreateMap happy_var_2
	)
happyReduction_6 _ _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_1  6 happyReduction_7
happyReduction_7 _
	 =  HappyAbsSyn6
		 (CEmpty
	)

happyReduce_8 = happyReduce 6 6 happyReduction_8
happyReduction_8 (_ `HappyStk`
	(HappyAbsSyn7  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn7  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn6
		 (CTreasure happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_9 = happyReduce 6 6 happyReduction_9
happyReduction_9 (_ `HappyStk`
	(HappyAbsSyn7  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn7  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn6
		 (CEnemy happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_10 = happySpecReduce_1  6 happyReduction_10
happyReduction_10 _
	 =  HappyAbsSyn6
		 (CExit
	)

happyReduce_11 = happyReduce 5 7 happyReduction_11
happyReduction_11 (_ `HappyStk`
	(HappyTerminal (TInt happy_var_4)) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TInt happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn7
		 (Npc happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_12 = happyReduce 7 7 happyReduction_12
happyReduction_12 (_ `HappyStk`
	(HappyTerminal (TInt happy_var_6)) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn9  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn7  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn7
		 (Item happy_var_2 happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_13 = happySpecReduce_1  7 happyReduction_13
happyReduction_13 (HappyTerminal (TVar happy_var_1))
	 =  HappyAbsSyn7
		 (Var happy_var_1
	)
happyReduction_13 _  = notHappyAtAll 

happyReduce_14 = happyReduce 11 8 happyReduction_14
happyReduction_14 (_ `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TInt happy_var_9)) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TInt happy_var_7)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TInt happy_var_4)) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TInt happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn8
		 (Player happy_var_2 happy_var_4 happy_var_7 happy_var_9
	) `HappyStk` happyRest

happyReduce_15 = happySpecReduce_1  9 happyReduction_15
happyReduction_15 _
	 =  HappyAbsSyn9
		 (Dmg
	)

happyReduce_16 = happySpecReduce_1  9 happyReduction_16
happyReduction_16 _
	 =  HappyAbsSyn9
		 (Hp
	)

happyNewToken action sts stk [] =
	action 25 25 notHappyAtAll (HappyState action) sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = action i i tk (HappyState action) sts stk tks in
	case tk of {
	TAss -> cont 10;
	TOpen -> cont 11;
	TClose -> cont 12;
	TComma -> cont 13;
	TPlayer -> cont 14;
	TCell -> cont 15;
	TMap -> cont 16;
	TDmg -> cont 17;
	THp -> cont 18;
	TInt happy_dollar_dollar -> cont 19;
	TVar happy_dollar_dollar -> cont 20;
	TEmpty -> cont 21;
	TTreasure -> cont 22;
	TEnemy -> cont 23;
	TExit -> cont 24;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 25 tk tks = happyError' (tks, explist)
happyError_ explist _ tk tks = happyError' ((tk:tks), explist)

newtype HappyIdentity a = HappyIdentity a
happyIdentity = HappyIdentity
happyRunIdentity (HappyIdentity a) = a

instance Prelude.Functor HappyIdentity where
    fmap f (HappyIdentity a) = HappyIdentity (f a)

instance Applicative HappyIdentity where
    pure  = HappyIdentity
    (<*>) = ap
instance Prelude.Monad HappyIdentity where
    return = pure
    (HappyIdentity p) >>= q = q p

happyThen :: () => HappyIdentity a -> (a -> HappyIdentity b) -> HappyIdentity b
happyThen = (Prelude.>>=)
happyReturn :: () => a -> HappyIdentity a
happyReturn = (Prelude.return)
happyThen1 m k tks = (Prelude.>>=) m (\a -> k a tks)
happyReturn1 :: () => a -> b -> HappyIdentity a
happyReturn1 = \a tks -> (Prelude.return) a
happyError' :: () => ([(Token)], [Prelude.String]) -> HappyIdentity a
happyError' = HappyIdentity Prelude.. (\(tokens, _) -> parseError tokens)
parse tks = happyRunIdentity happySomeParser where
 happySomeParser = happyThen (happyParse action_0 tks) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


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
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- $Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp $










































data Happy_IntList = HappyCons Prelude.Int Happy_IntList








































infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is ERROR_TOK, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action









































indexShortOffAddr arr off = arr Happy_Data_Array.! off


{-# INLINE happyLt #-}
happyLt x y = (x Prelude.< y)






readArrayBit arr bit =
    Bits.testBit (indexShortOffAddr arr (bit `Prelude.div` 16)) (bit `Prelude.mod` 16)






-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Prelude.Int ->                    -- token number
         Prelude.Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Prelude.- ((1) :: Prelude.Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             _ = nt :: Prelude.Int
             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n Prelude.- ((1) :: Prelude.Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Prelude.- ((1)::Prelude.Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction









happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery (ERROR_TOK is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  ERROR_TOK tk old_st CONS(HAPPYSTATE(action),sts) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        DO_ACTION(action,ERROR_TOK,tk,sts,(saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ((HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = Prelude.error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `Prelude.seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.

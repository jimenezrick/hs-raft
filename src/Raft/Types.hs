module Raft.Types where

type FsmApply a b e = a -> b -> Either e a

data Fsm a b e = Fsm
  { fsmState :: a,
    fsmApply :: FsmApply a b e
  }

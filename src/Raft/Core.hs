{-# LANGUAGE GADTs #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Raft.Core where

import Control.Monad (void)
import qualified Data.ByteString.Char8 as BS
import Foreign.C.Types
import Foreign.Marshal.Alloc
import Foreign.Ptr
import Foreign.StablePtr
import Foreign.Storable
import qualified Raft.C as CRaft
import Raft.Types

fsmApplyHook :: (Show a, a ~ b) => FsmApply a b e -> Ptr CRaft.RaftFsm -> Ptr CRaft.RaftBuffer -> Ptr (Ptr ()) -> IO CInt
fsmApplyHook apply cfsm buf res = do
  CRaft.RaftFsm v d <- peek cfsm

  curState <- deRefStablePtr $ castPtrToStablePtr d
  putStrLn $ "Current state: " ++ show curState
  freeStablePtr $ castPtrToStablePtr d
  let Right newState = apply curState curState

  sptrS <- newStablePtr newState
  poke cfsm $ CRaft.RaftFsm v (castStablePtrToPtr sptrS)

  putStrLn $ "Tick " ++ show newState
  ptrRes :: Ptr CInt <- calloc
  poke res (castPtr ptrRes)

  return 0

run :: (Show a, a ~ b) => String -> CUInt -> Fsm a b e -> IO ()
run dirPath nodeID fsm = do
  ptrInitState <- newStablePtr $ fsmState fsm
  applyCb <- CRaft.mkApplyCallback . fsmApplyHook $ fsmApply fsm
  void $ CRaft.raftRun dirPath nodeID (castStablePtrToPtr ptrInitState) applyCb

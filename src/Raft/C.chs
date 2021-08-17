module Raft.C where

import Control.Monad (liftM2)
import Foreign.C.Types
import Foreign.C.String
import Foreign.Ptr
import Foreign.Storable

#include "raft.h"
#include "helpers.h"

#c
typedef struct raft_fsm raft_fsm;
#endc

type ApplyCallback = Ptr RaftFsm -> Ptr RaftBuffer -> Ptr (Ptr ()) -> IO CInt

foreign import ccall "wrapper"
  mkApplyCallback :: ApplyCallback -> IO (FunPtr ApplyCallback)

data RaftFsm = RaftFsm { fsmVersion :: CInt, fsmData :: Ptr () }

instance Storable RaftFsm where
  sizeOf    _           = {#sizeof raft_fsm#}
  alignment _           = {#alignof raft_fsm#}
  peek      ptr          = liftM2 RaftFsm
                              ({#get raft_fsm.version#} ptr)
                              ({#get raft_fsm.data#} ptr)
  poke      ptr (RaftFsm v d) = do
                                   {#set raft_fsm.version#} ptr v
                                   {#set raft_fsm.data#} ptr d

data RaftBuffer -- XXX

{#pointer *raft_fsm as PtrRaftFsm -> RaftFsm#}

{#pointer *raft_buffer as PtrRaftBuffer -> RaftBuffer#}

{#fun raft_run as ^ {`String', `CUInt', `Ptr ()', id `FunPtr ApplyCallback'} -> `CInt'#}

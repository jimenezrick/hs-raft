{-# LANGUAGE LambdaCase #-}

import Raft.Core as Raft
import Raft.Types as Raft
import System.Environment (getArgs)

main :: IO ()
main = do
  [i] <- getArgs
  let dirPath = "/tmp/raft/" ++ i
      nodeID = read i
  Raft.run dirPath nodeID fsm
  where
    fsm :: Fsm Int Int String
    fsm = Fsm 0 (\s u -> Right (s + 1))

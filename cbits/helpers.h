#pragma once

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <raft.h>
#include <raft/uv.h>

int raft_run(const char *dir, unsigned id,
        void *init_data,
        int (*applyCB)(struct raft_fsm *fsm,
                     const struct raft_buffer *buf,
                     void **result)
        );

#!/bin/bash
xmrig --no-color --randomx-1gb-pages --donate-level $DONATE_LVL --cuda --cuda-loader=$LIBXMRIG_CUDA -o $POOL:$PORT -u $WALLET -k --tls --rig-id $RIG_ID
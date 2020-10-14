#!/bin/bash
#xmrig --donate-level $DONATE_LVL --cuda --cuda-loader=$LIBXMRIG_CUDA -o $POOL:$PORT -u $WALLET -k --tls --rig-id $RIG_ID
xmrig --donate-level $DONATE_LVL -o $POOL:$PORT -u $WALLET -k --tls --rig-id $RIG_ID  --randomx-1gb-pages -t $(nproc)
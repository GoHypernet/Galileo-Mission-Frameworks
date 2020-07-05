#!/bin/sh
if test -x /usr/bin/nvidia-smi; then
    ARCH="/namd-2.14b2-cuda/NAMD_2.14b2_Linux-x86_64-multicore-CUDA"
else
    ARCH="/namd-2.14b2/NAMD_2.14b2_Linux-x86_64-multicore"
fi
echo ${ARCH}
${ARCH}/namd2 $@

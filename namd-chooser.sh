#!/bin/sh
FLAGS=`cat /proc/cpuinfo | grep ^flags | head -1`
if echo $FLAGS | grep " avx512f " > /dev/null; then
    ARCH="/namd-2.14b2-cuda/NAMD_2.14b2_Linux-x86_64-multicore-CUDA"
elif echo $FLAGS | grep " avx2 " > /dev/null; then
    ARCH="/namd-2.14b2-cuda/NAMD_2.14b2_Linux-x86_64-multicore-CUDA"
elif echo $FLAGS | grep " avx " > /dev/null; then
    ARCH="/namd-2.14b2-cuda/NAMD_2.14b2_Linux-x86_64-multicore-CUDA"
else
    ARCH="/namd-2.14b2/NAMD_2.14b2_Linux-x86_64-multicore"
fi
echo ${ARCH}
${ARCH}/namd2 $@
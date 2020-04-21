#!/bin/bash
stata-mp -b $DOFILE.do $STATAARGS &
sleep 1
tail --pid $! -n +1 -f $DOFILE.log
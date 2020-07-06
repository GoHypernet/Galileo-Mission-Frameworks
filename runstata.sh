#!/bin/bash
if test -e ./stata.lic; then
   echo "License file detected, starting Stata"
   mv ./stata.lic /usr/local/stata16/stata.lic
   stata-mp -b $DOFILE.do $STATAARGS &
   sleep 1
   tail --pid $! -n +1 -f $DOFILE.log
else
   echo "Please provide a valid stata.lic file for Stata16"
fi

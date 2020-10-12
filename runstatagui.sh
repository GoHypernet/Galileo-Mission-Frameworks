#!/bin/bash
if test -e ./stata.lic; then
   echo "License file detected, starting Stata"
   mv ./stata.lic /home/galileo/stata16/stata.lic
   sleep 1
   $STATA
elif test -e ./STATA.LIC; then
   echo "License file detected, starting Stata"
   mv ./STATA.LIC /home/galileo/stata16/stata.lic
   sleep 1
   $STATA 
else
   echo "--------------------------------------------------------------------------"
   echo "Please provide a valid stata.lic file for Stata16"
   echo "See https://galileoapp.io/gettingstarted/tutorial-stata for more details"
   echo "--------------------------------------------------------------------------"
fi

#!/bin/bash
if test -e /home/galileo/stata.lic; then
   echo "License file detected, placing in Stata path."
   mv /home/galileo/stata.lic /usr/local/stata16/stata.lic
elif test -e /home/galileo/STATA.LIC; then
   echo "License file detected, placing in Stata path."
   mv /home/galileo/STATA.LIC /usr/local/stata16/stata.lic
elif test -e /theia/stata.lic; then
   echo "License file detected, placing in Stata path."
   mv /theia/stata.lic /usr/local/stata16/stata.lic
elif test -e /theia/STATA.LIC; then
   echo "License file detected, placing in Stata path."
   mv /theia/STATA.LIC /usr/local/stata16/stata.lic
else
   echo "--------------------------------------------------------------------------"
   echo "Please provide a valid stata.lic file for Stata16"
   echo "--------------------------------------------------------------------------"
fi

#!/bin/bash
if test -e $inputfile; then
	mafft --thread $(nproc) --auto $inputfile > $outputfile
else
	echo "-------------------------------------------------"
	echo "Could not find your input file: " $inputfile
	echo "Please upload this file to your Mission context."
	echo "-------------------------------------------------"
fi 
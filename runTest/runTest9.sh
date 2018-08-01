#!/bin/bash

echo "Testing prepPattern.R"
echo "..making uniform bin table"
prepPattern.R --method=uniform --dataSet=/usr/src/tameNMR/test/test_data/out_norm_PQN.csv --output=/tmp/bins_uniform.csv --binSize=0.05

echo "..making intelligent bin table"
prepPattern.R --method=intelligent --dataSet=/usr/src/tameNMR/test/test_data/out_norm_PQN.csv --output=/tmp/bins_intelligent.csv

files=(bins_uniform.csv bins_intelligent.csv)
for i in ${files[*]}; do

	if [ $(wc -l /tmp/$i | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then 
     		echo "line numbers do not match"
     		wc -l /tmp/$i
     		wc -l /usr/src/tameNMR/test/outputs/$i
     		exit 1
	fi
done

exit 0

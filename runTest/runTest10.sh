#!/bin/bash

echo "Testing QuantilePlot.R"
QuantilePlot.R --input=/usr/src/tameNMR/test/test_data/out_norm_PQN.csv --outDir=/tmp --output=/tmp/out_quantiles.html --ppmInt=4-3 --pltMean=Y

files=(out_quantiles.html QuantilePlot.png)
for i in ${files[*]}; do

	if [ $(wc -l /tmp/$i | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then 
     		echo "lines number do not match"
     		wc -l /tmp/$i
     		wc -l /usr/src/tameNMR/test/outputs/$i
     		exit 1
	fi
done

exit 0

#!/bin/bash

echo "Testing Normalise.R"
Normalise.R --input=/usr/src/tameNMR/test/test_data/out_aligned.csv --output=/tmp/out_norm_PQN.csv --type=PQN

Normalise.R --input=/usr/src/tameNMR/test/test_data/out_aligned.csv --output=/tmp/out_norm_totArea.csv --type=totInt

Normalise.R --input=/usr/src/tameNMR/test/test_data/out_aligned.csv --output=/tmp/out_norm_refPeak.csv --type=refPeak --param=0.32-0.33

files=(out_norm_PQN.csv out_norm_totArea.csv out_norm_refPeak.csv)
for i in ${files[*]}; do
	if [ $(md5sum /tmp/$i | cut -d" " -f1) != $(md5sum /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then 
     		echo "check sums do not match"
     		md5sum /tmp/$i
     		md5sum /usr/src/tameNMR/test/outputs/$i
     		exit 1
	fi
done

exit 0

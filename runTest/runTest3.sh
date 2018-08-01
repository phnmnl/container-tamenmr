#!/bin/bash

echo "Testing BinSpectra.R"
echo "testing uniform binning"
BinSpectra.R --input=/usr/src/tameNMR/test/test_data/out_norm_PQN.csv --output=/tmp/out_binned_uniform.csv --pattern=/usr/src/tameNMR/test/output/bins_uniform.csv

echo "testing binning with bruker bin table"
BinSpectra.R --input=/usr/src/tameNMR/test/test_data/out_norm_PQN.csv --output=/tmp/out_binned_bruker.csv --pattern=/usr/src/tameNMR/test/output/bins_bruker.csv

echo "testing binning with custom bin table"
BinSpectra.R --input=/usr/src/tameNMR/test/test_data/out_norm_PQN.csv --output=/tmp/out_binned_fromCsv.csv --pattern=/usr/src/tameNMR/test/output/bins_fromCsv.csv

echo "testing intelligent binning"
BinSpectra.R --input=/usr/src/tameNMR/test/test_data/out_norm_PQN.csv --output=/tmp/out_binned_intelligent.csv --pattern=/usr/src/tameNMR/test/output/bins_intelligent.csv

files=(out_binned_uniform.csv out_binned_bruker.csv out_binned_fromCsv.csv out_binned_intelligent.csv)
for i in ${files[*]}; do

	if [ $(md5sum /tmp/$i | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then 
     		echo "check sums do not match"
     		md5sum /tmp/$i
     		md5sum /usr/src/tameNMR/test/outputs/$i
     		exit 1
	fi
done

exit 0

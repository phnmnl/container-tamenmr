#!/bin/bash

echo "Testing PeakPick.R"
PeakPick.R --input=/usr/src/tameNMR/test/test_data/out_slice.csv --output=/tmp/out_peaks.csv

files=(out_peaks.csv)
for i in ${files[*]}; do
	if [ $(wc -l /tmp/$i | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then 
     		echo "line numbers do not match"
     		wc -l /tmp/$i
     		wc -l /usr/src/tameNMR/test/outputs/$i
     		exit 1
	fi
done

exit 0

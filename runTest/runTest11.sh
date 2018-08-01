#!/bin/bash

echo "Testing SliceSpectra.R"
SliceSpectra.R --input=/usr/src/tameNMR/test/test_data/Out_Import2csv.csv --output=/tmp/out_slice.csv --retainPpm=10-0 --remWater=Y

files=(out_slice.csv)
for i in ${files[*]}; do

	if [ $(md5sum /tmp/$i | cut -d" " -f1) != $(md5sum /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then 
     		echo "check sums do not match"
     		md5sum /tmp/$i
     		md5sum /usr/src/tameNMR/test/outputs/$i
     		exit 1
	fi
done

exit 0

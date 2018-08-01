#!/bin/bash

echo "Testing PLSDA.R"
PLSDA.R --input=/usr/src/tameNMR/test/test_data/data.csv --output=/tmp/plsda_out --outdir=/tmp --factorFile=/usr/src/tameNMR/test/test_data/fact.csv --factorCol=2

files=(Diagnostics.png PLSDA_Scores.png VIP.png results.Rmd plsda_out.html)
for i in ${files[*]}; do

	if [ $(md5sum /tmp/$i | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then 
     		echo "check sums do not match"
     		md5sum /tmp/$i
     		md5sum /usr/src/tameNMR/test/outputs/$i
     		exit 1
	fi
done

exit 0

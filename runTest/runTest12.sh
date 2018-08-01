#!/bin/bash

echo "Testing Ttest.R"
Ttest.R --input=/usr/src/tameNMR/test/test_data/data.csv --output=/tmp/ttest_out_ --outdir=/tmp --factorFile=/usr/src/tameNMR/test/test_data/fact.csv --factorCol=1 --tails=two.sided --paired=N --conf_level=0.05

files=(ttest_out_ meanBars.png p_Vals.png results.Rmd results.txt)
for i in ${files[*]}; do

	if [ $(md5sum /tmp/$i | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then 
     		echo "check sums do not match"
     		md5sum /tmp/$i
     		md5sum /usr/src/tameNMR/test/outputs/$i
     		exit 1
	fi
done

exit 0

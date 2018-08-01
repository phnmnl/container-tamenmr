#!/bin/bash

echo "Testing PCA.R"
mkdir /tmp/pca_out
PCA.R --input=/usr/src/tameNMR/test/test_data/data.csv --output=/tmp/pca_out/pca_out --outdir=/tmp/pca_out --factorFile=/usr/src/tameNMR/test/test_data/fact.csv --factorCol=2 --pcs="1-2,2-3,1-3" --scale=Y --showScores=Y --showLoadings=Y --showVarAcc=Y

files=(PC_1-2_loadings.png PC_1-2_scores.png PC_1-3_loadings.png PC_1-3_scores.png PC_2-3_loadings.png PC_2-3_scores.png VarAcc.png results.Rmd)
for i in ${files[*]}; do

	if [ $(md5sum /tmp/pca_out/$i | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/pca_out/$i | cut -d" " -f1) ]; then 
     		echo "check sums do not match"
     		md5sum /tmp/pca_out/$i
     		md5sum /usr/src/tameNMR/test/outputs/pca_out/$i
     		exit 1
	fi
done

if [ $(md5sum /tmp/pca_out.html | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/pca_out.html | cut -d" " -f1) ]; then
	echo "check sums do not match"
	md5sum /tmp/pca_out/$i
	md5sum /usr/src/tameNMR/test/outputs/pca_out/$i
	exit 1
fi

exit 0

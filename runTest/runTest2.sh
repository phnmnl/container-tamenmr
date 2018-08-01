#!/bin/bash

echo "Testing Anova.R"
mkdir /tmp/anova_out
Anova.R --input=/usr/src/tameNMR/test/test_data/data.csv --output=/tmp/anova_out/anova_out --outdir=/tmp/anova_out --factorFile=/usr/src/tameNMR/test/test_data/fact.csv --factorCol=2 --conf_level=0.05 --adjust=BH

for i in $(ls /usr/src/tameNMR/test/outputs/anova_out/); do
    if [ $(md5sum /tmp/anova_out/$i | cut -d" " -f1) != $(md5sum /usr/src/tameNMR/test/outputs/$i | cut -d" " -f1) ]; then
        echo "check sums do not match"
        md5sum /tmp/anova_out/$i
        md5sum /usr/src/tameNMR/test/outputs/$i
        exit 1
    fi
done

if [ $(md5sum /tmp/anova_out/anova_out.html | cut -d" " -f1) != $(md5sum /usr/src/tameNMR/test/outputs/anova_out.html | cut -d" " -f1) ]; then 
    echo "check sums do not match"
    md5sum /tmp/anova_out/anova_out.html
    md5sum /usr/src/tameNMR/test/outputs/anova_out.html
    exit 1
fi

exit 0

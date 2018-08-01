#!/bin/bash

echo "Testing Align.R"
Align.R --inData=/usr/src/tameNMR/test/test_data/out_slice.csv --inPeaks=/usr/src/tameNMR/test/test_data/out_peaks.csv --output=/tmp/out_aligned.csv --retainPpm=10-0 --remWater=Y

if [ $(md5sum /tmp/out_aligned.csv | cut -d" " -f1) != $(md5sum /usr/src/tameNMR/test/outputs/out_aligned.csv | cut -d" " -f1) ]; then 
    echo "check sums do not match"
    md5sum /tmp/out_aligned.csv
    md5sum /usr/src/tameNMR/test/outputs/out_aligned.csv 
    exit 1
fi

exit 0

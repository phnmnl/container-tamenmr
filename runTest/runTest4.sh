#!/bin/bash

echo "Testing import2csv.py"

import2csv.py /usr/src/tameNMR/test/test_data/CPMG_exp.zip /tmp/import2csvOut.csv data

if [ $(wc -l /tmp/import2csvOut.csv | cut -d" " -f1) != $(wc -l /usr/src/tameNMR/test/outputs/import2csvOut.csv | cut -d" " -f1) ]; then 
    echo "line numbers do not match"
    wc -l /tmp/import2csvOut.csv
    wc -l /usr/src/tameNMR/test/outputs/import2csvOut.csv
    exit 1
fi

exit 0

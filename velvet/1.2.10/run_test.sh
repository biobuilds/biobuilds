#!/bin/bash

cd tests
sed -i.bak '
    s,VH=.*$,VH="${PREFIX}/bin/velveth",;
    s,VG=.*$,VG="${PREFIX}/bin/velvetg",;
    ' run-tests.functions
./run-tests.sh

cd ../data
velveth . 21 -shortPaired test_reads.fa
velvetg .

#!/bin/bash

# Following the 2020plus quick start:
# http://2020plus.readthedocs.io/en/latest/quickstart.html

set -e -x

EX_TARBALL_URL='http://karchinlab.org/data/2020+/pancan_example.tar.gz'
EX_TARBALL=`basename "$EX_TARBALL_URL"`

test -f "$EX_TARBALL" || curl -s "$EX_TARBALL_URL"

tar -xf "$EX_TARBALL"
cd pancan_example

2020plus.py features \
    -og-test oncogene.txt \
    -tsg-test tsg.txt \
    --summary summary_pancan.txt \
    -o features_pancan.txt

2020plus.py --out-dir=result_compare classify \
    -f features_pancan.txt \
    -nd simulated_null_dist.txt

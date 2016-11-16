#!/bin/bash

set -e -x -o pipefail

tar -xf test-data.tar.gz
if [ -d output ]; then
    rm -rf output/*
else
    mkdir output
fi

# Global alignment
needle hoxa1-mrna-hsa.fa hoxb1-mrna.fa -outfile output/test-needle-mrna.txt \
    -gapopen 10 -gapextend 0.5 -datafile EDNASIMPLE
needle hoxa1-prot-hsa.fa hoxb1-prot.fa -outfile output/test-needed-prot.txt \
    -gapopen 10 -gapextend 0.5 -datafile EPAM60

# Local alignment
water hoxa1-mrna-hsa.fa hoxb1-mrna.fa -outfile output/test-water-mrna.txt \
    -gapopen 10 -gapextend 0.5 -datafile EDNASIMPLE
water hoxa1-prot-hsa.fa hoxb1-prot.fa -outfile output/test-water-prot.txt \
    -gapopen 10 -gapextend 0.5 -datafile EPAM60

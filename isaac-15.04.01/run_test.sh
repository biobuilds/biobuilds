#!/bin/bash
set -o pipefail

tar -xf test-data.tar.gz
rm -rf isaac-ref temp aligned

isaac-sort-reference -g reference/lambda_virus.fa -o isaac-ref
[ -f isaac-ref/sorted-reference.xml ] || \
    { echo "ERROR: Unable to index reference genome!" >&2; exit 1; }

# WARNING: "-m 4" tells iSAAC to use up to 4-GB for its work; this seems to be
# the minimum value needed for iSAAC to run on ppc64le. Be careful when
# building and testing this package on machines with smaller amounts of RAM.
isaac-align -m 4 --variable-read-length yes -r isaac-ref/sorted-reference.xml \
    -b ./reads --base-calls-format fastq -t temp -o aligned
[ -d aligned ] || \
    { echo "ERROR: Unable to align reads!" >&2; exit 1; }

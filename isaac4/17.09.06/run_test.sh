#!/bin/bash
set -e -x
set -o pipefail

# Copy example data to local test directory
mkdir -p reads reference
EX_DIR="${PREFIX}/share/Isaac-04.${PKG_VERSION}/data/examples/PhiX"
find "${EX_DIR}" -type f -name 'lane1_*.fastq' \
    -exec cp -fv {} reads \;
find "${EX_DIR}" -type f -name 'phix.fa*' \
    -exec cp -fv {} reference \;

# Start from a clean state
rm -rf isaac-ref temp aligned

# Index the reference genome
isaac-sort-reference -g reference/phix.fa -o isaac-ref
[ -f isaac-ref/sorted-reference.xml ] || \
    { echo "ERROR: Unable to index reference genome!" >&2; exit 1; }

# Perform the alignment
# WARNING: Even though the test data is really small (2500 reads; ~5.3-kbp
# reference genome), the memory limit ("-m") argument needs to be fairly large.
# On the Lab7 Systems build/test servers, values smaller than 32-GB will cause
# "isaac-align" to fail with "std::bad_alloc" errors.
isaac-align \
    -r isaac-ref/sorted-reference.xml \
    -b ./reads -f fastq \
    -t ./temp \
    -o ./aligned \
    -m 32

# Check the alignments
[ -d aligned ] || \
    { echo "ERROR: Unable to align reads!" >&2; exit 1; }

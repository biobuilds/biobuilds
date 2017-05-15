#!/bin/bash

set -o pipefail -u

seqtk seq -A -q 2 "test.fq.gz" > test.fa
# TODO: Additional tests

md5sum -c - <<EOF
02085749221f2d2cea13ea65c4d82547  test.fa
EOF


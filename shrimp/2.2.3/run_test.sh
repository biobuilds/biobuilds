#!/bin/bash
set -u -o pipefail

for d in reads reference; do
    cp -rv "${PREFIX}/share/mapper-test-data/${d}/" ${d}/
done

REFNAME="lambda_virus"
gmapper --qv-offset 33 \
    -1 "reads/reads_1.fq" \
    -2 "reads/reads_2.fq" \
    "reference/${REFNAME}.fa" \
    > "test.sam"

md5sum -c - <<EOF
3389d8a0a558875d981818540134095b  test.sam
EOF

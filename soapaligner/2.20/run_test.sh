#!/bin/bash

for d in reads reference; do
    cp -rv "${PREFIX}/share/mapper-test-data/${d}/" ${d}/
done

REFERENCE="lambda_virus"
2bwt-builder "reference/${REFERENCE}.fa"

soap -D "reference/${REFERENCE}.fa.index" \
    -a "reads/reads_1.fq" \
    -b "reads/reads_2.fq" \
    -o "soap-reads-mapped.txt" \
    -u "soap-reads-unmapped.txt" \
    -2 "soap-reads-unaligned.txt" \
    -p 2 -m 0 -x 100 \
    2>&1 | tee soap-test.txt

md5sum -c - <<EOF
e2d8b68d05c661aa00378908bcaa8255  soap-reads-mapped.txt
a725391200e262470fa980f784fb57be  soap-reads-unaligned.txt
9d172086dd2351b7662054403d670663  soap-reads-unmapped.txt
EOF

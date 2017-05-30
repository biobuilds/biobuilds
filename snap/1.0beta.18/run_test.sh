#!/bin/bash
set -e -x -o pipefail

for d in reads reference; do
    mkdir -p $d
    cp -rv "${PREFIX}/share/mapper-test-data/${d}/." ${d}
done

REFNAME="lambda_virus"

# Use only one thread so the test results are reproducible
snap-aligner index reference/${REFNAME}.fa reference -t1
snap-aligner single reference reads/reads_1.fq -o reads_1.sam -t 1
snap-aligner single reference reads/reads_2.fq -o reads_2.sam -t 1
snap-aligner paired reference reads/reads_1.fq reads/reads_2.fq -o paired.sam -t 1

md5sum -c - <<EOF
060b804aa35d63664084191c82207097  reference/Genome
eaa738aec73837cf0b954f0526cc0f33  reference/GenomeIndex
784e6c6b70e38d8332b63de498a0facb  reference/GenomeIndexHash
d41d8cd98f00b204e9800998ecf8427e  reference/OverflowTable
f2127dff5cb81037207e342348df07eb  paired.sam
b9924a04f6142744beb04c53ba9fbd01  reads_1.sam
b7f9093a13a69073062cae11f43f0557  reads_2.sam
EOF

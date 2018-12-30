#!/bin/bash

hisat2-build \
    example/reference/22_20-21M.fa \
    --snp example/reference/22_20-21M.snp \
    22_20-21M_snp

hisat2 -x example/index/22_20-21M_snp \
    -f -U example/reads/reads_1.fa \
    -S unpaired.sam

hisat2 -x example/index/22_20-21M_snp \
    -f -1 example/reads/reads_1.fa -2 example/reads/reads_2.fa \
    -S paired-end.sam

hisat2 --version

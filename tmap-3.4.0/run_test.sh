#!/bin/bash

tar -xf "test-data.tar.bz2"
rm -f *.sam     # clean up test directory

tmap-ion index -f reference/lambda_virus.fa

# Un-paired reads
for ii in 1 2 3 4; do
    echo "Un-paired using 'map$ii'..."
    tmap-ion map${ii} -f reference/lambda_virus.fa \
        -r reads/reads_1.fq -s tmap-map${ii}-unpaired.sam
done

# Paired-end reads
for ii in 1 2 3 4; do
    echo "Paired-end using 'map$ii'..."
    tmap-ion map${ii} -f reference/lambda_virus.fa \
        -Q 2 -r reads/reads_1.fq -r reads/reads_2.fq \
        -s tmap-map${ii}-paired.sam
done

# Multi-stage mapping
echo "un-paired using 'mapall' with 2 threads..."
tmap-ion mapall -f reference/lambda_virus.fa -n 2 \
    -r reads/reads_1.fq -s tmap-mapall-unpaired.sam \
    -v stage1 map1 map2 map3
echo "paired-end using 'mapall' with 2 threads..."
tmap-ion mapall -f reference/lambda_virus.fa -n 2 \
    -Q 2 -r reads/reads_1.fq -r reads/reads_2.fq \
    -s tmap-mapall-unpaired.sam -v stage1 map1 map2 map3

## DISBALED TEST: SEGFAULTS ON X86 LINUX AND OSX
## Vectorized Smith-Waterman
#echo "Un-paired using 'mapvsw'..."
#tmap-ion mapvsw -f reference/lambda_virus.fa \
#    -r reads/reads_1.fq -s tmap-mapvsw-unpaired.sam
#echo "Paired-end using 'mapvsw'..."
#tmap-ion mapvsw -f reference/lambda_virus.fa \
#    -Q 2 -r reads/reads_1.fq -r reads/reads_2.fq \
#    -s tmap-mapvsw-paired.sam

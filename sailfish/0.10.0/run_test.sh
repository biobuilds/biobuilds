#!/bin/bash

# Assuming GNU(-compatible) tar here
tar --strip=1 -xf sample_data.tgz

# Re-running test sequence from "cmake/SimpleTest.cmake" just to make sure we
# didn't break anything (too badly) when inside in a "clean" conda environment.
sailfish index -t transcripts.fasta -o sample_index --force
sailfish quant -i sample_index -l IU \
    -1 reads_1.fastq -2 reads_2.fastq \
    -o sample_quant
test -f sample_quant/quant.sf

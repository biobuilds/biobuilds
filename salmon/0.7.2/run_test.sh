#!/bin/bash
set -e -x

# Assuming GNU(-compatible) tar here
tar --strip=1 -xf sample_data.tgz

# Re-running test sequences in source "cmake/TestSalmonFMD.cmake" and
# "cmake/TestSalmonQuasi.cmake" files just to make sure we didn't break
# anything with our post-build munging.
salmon index -t transcripts.fasta -i sample_salmon_fmd_index --type fmd
salmon quant -i sample_salmon_fmd_index -l IU \
    -1 reads_1.fastq -2 reads_2.fastq \
    -o sample_salmon_fmd_quant
test -f sample_salmon_fmd_quant/quant.sf

salmon index -t transcripts.fasta -i sample_salmon_quasi_index --type quasi
salmon quant -i sample_salmon_quasi_index -l IU \
    -1 reads_1.fastq -2 reads_2.fastq \
    -o sample_salmon_quasi_quant
test -f sample_salmon_quasi_quant/quant.sf

#!/bin/bash
set -e -x -o pipefail

# Assuming the "test" directory has been copied out the sources
cd test
snippy --outdir test1 --force --ref example.fna --pe1 reads_R1.fastq.gz --pe2 reads_R2.fastq.gz
snippy --outdir test2 --force --ref example.fna --R1 reads_R1.fastq.gz --R2 reads_R2.fastq.gz
snippy --outdir test3 --force --ref example.gbk --R1 reads_R1.fastq.gz --pe2 reads_R2.fastq.gz
snippy --outdir test4 --force --ref example.gbk --se reads_R1.fastq.gz

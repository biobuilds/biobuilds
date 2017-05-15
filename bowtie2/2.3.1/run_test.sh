#!/bin/bash
set -ex -o pipefail

# Basic sanity checks
bowtie2 --help &>/dev/null
bowtie2-align-s --help &>/dev/null
bowtie2-align-l --help &>/dev/null
bowtie2-build --help &>/dev/null
bowtie2-build-s --help &>/dev/null
bowtie2-build-l --help &>/dev/null
bowtie2-inspect --help &>/dev/null
bowtie2-inspect-s --help &>/dev/null
bowtie2-inspect-l --help &>/dev/null

# Run the lambda phage example
REFNAME="lambda_virus"
SEED=12345

cd example

bowtie2-build "reference/${REFNAME}.fa" "${REFNAME}"

bowtie2 --seed ${SEED} -x lambda_virus \
    -U reads/reads_1.fq \
    -S se.sam

bowtie2 --seed ${SEED} -x lambda_virus \
    -1 reads/reads_1.fq \
    -2 reads/reads_2.fq \
    -S pe.sam

bowtie2 --seed ${SEED} -x lambda_virus \
    --local -U reads/longreads.fq \
    -S long.sam

#!/bin/bash
set -x -e -o pipefail

PRE="transcripts"

FASTA="${PRE}.fasta.gz"
READS1="reads_1.fastq.gz"
READS2="reads_2.fastq.gz"

index="${PRE}.kidx"
output="kallisto_out"

mv test/* .

kallisto index -i "${index}" "${FASTA}"
kallisto quant -i "${index}" -b 30 -o "${output}" "${READS1}" "${READS2}"

for fn in abundance.h5 abundance.tsv run_info.json; do
    test -f "${output}/${fn}" || \
        { echo "ERROR: Could not find output file $fn" >&2; exit 1;}
done

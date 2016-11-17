#!/bin/bash

# Testing basic set of commands to downloads and outputs FASTQ files; based on
# tutorial at <https://github.com/ncbi/sra-tools/wiki/Download-On-Demand>.

RUN_ID="ERR1110123"

abort() {
    echo "ERROR: ${1:-UNKNOWN!}" >&2
    exit 1
}

[ -d "$PWD/ncbi" ] && rm -rf "$PWD/ncbi"
vdb-config -s "/repository/user/main/public/root=${PWD}/ncbi/public"

# Limit to 2-MB download so tests don't take forever to run
prefetch -X 2048 "$RUN_ID"
[ "$(srapath $RUN_ID)" == "${PWD}/ncbi/public/sra/${RUN_ID}.sra" ] || \
    abort "$RUN_ID.sff downloaded into wrong directory!"

sff-dump "$RUN_ID"
[ -f "${RUN_ID}.sff" ] || abort "${RUN_ID}.sff not found!"

fastq-dump "$RUN_ID"
[ -f "${RUN_ID}.fastq" ] || abort "${RUN_ID}.fastq not found!"

echo -e "\n*** Verifying checksums ***"
md5sum -c - <<EOF
6a0f86e6bcc4c798bfa4aae071e2e800  ${RUN_ID}.fastq
42b7024f7a21e4c84773b56a9640e81d  ${RUN_ID}.sff
EOF

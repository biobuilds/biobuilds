#!/bin/bash
set -e -x -u -o pipefail

SHARE_DIR="${PREFIX}/libexec/${PKG_NAME}"
PRSEM_DIR="${SHARE_DIR}/pRSEM"
PRSEM_RLIB="${PRSEM_DIR}/RLib"

## Make sure we can load the pRSEM-provided SPP package
env R_LIBS="${PRSEM_RLIB}" Rscript -e 'library(spp);'


## Make sure the scripts at least start
convert-sam-for-rsem --help >/dev/null
rsem-calculate-expression --help >/dev/null
rsem-control-fdr --help >/dev/null
rsem-generate-ngvector --help >/dev/null
rsem-gff3-to-gtf --help >/dev/null
rsem-plot-transcript-wiggles --help >/dev/null
rsem-prepare-reference --help >/dev/null
rsem-run-ebseq --help >/dev/null
rsem-run-prsem-testing-procedure --help >/dev/null

# These scripts don't have a "-h"/"--help" option
#extract-transcript-to-gene-map-from-trinity
#rsem-generate-data-matrix
#rsem-gen-transcript-plots
#rsem-plot-model
#rsem-refseq-extract-primary-assembly

# The built binaries also don't have a "-h"/"--help" option
#rsem-bam2readdepth
#rsem-bam2wig
#rsem-build-read-index
#rsem-calculate-credibility-intervals
#rsem-extract-reference-transcripts
#rsem-for-ebseq-calculate-clustering-info
#rsem-get-unique
#rsem-parse-alignments
#rsem-preref
#rsem-run-em
#rsem-run-gibbs
#rsem-sam-validator
#rsem-scan-for-paired-end-reads
#rsem-simulate-reads
#rsem-synthesis-reference-transcripts
#rsem-tbam2gbam



## TODO: actual functional tests

#!/bin/bash

set -o pipefail

samtools view -h test.bam | samblaster -o samblaster.out
md5sum -c - << EOF
b4d64edf5279e9ff45046b46da48c4ca  samblaster.out
EOF

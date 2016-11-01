#!/bin/bash

set -o pipefail

samtools view -h test.bam | samblaster -o samblaster.out
md5sum -c - << EOF
de5a1ae90a0419cb54ec8b2a4344ceda  samblaster.out
EOF

#!/bin/bash

set -e -x -u -o pipefail

for d in reads reference; do
    cp -rv "${PREFIX}/share/mapper-test-data/${d}/" ${d}/
done

REFNAME="lambda_virus"

bwa index reference/${REFNAME}.fa

bwa aln -t2 reference/${REFNAME}.fa reads/longreads.fq > aln-se.sai
bwa samse -f aln-se.sam reference/${REFNAME}.fa \
    aln-se.sai reads/longreads.fq

bwa aln -t2 reference/${REFNAME}.fa reads/reads_1.fq > aln_1.sai
bwa aln -t2 reference/${REFNAME}.fa reads/reads_2.fq > aln_2.sai
bwa sampe -f aln-pe.sam reference/${REFNAME}.fa \
    aln_1.sai aln_2.sai reads/reads_1.fq reads/reads_2.fq

bwa mem -t2 reference/${REFNAME}.fa \
    reads/longreads.fq > mem-se.sam

bwa mem -t2 reference/${REFNAME}.fa \
    reads/reads_1.fq reads/reads_2.fq > mem-pe.sam

md5sum -c - <<EOF
c5a18088a0c677c9cdcebec36f2cf418  reference/lambda_virus.fa.amb
f98f8b2fcd7226a4ba0bd01d67a03e22  reference/lambda_virus.fa.ann
86b95928f5c901663ce25d41631a97db  reference/lambda_virus.fa.bwt
27c59f7f0708bb35ad99f502c2b33ab7  reference/lambda_virus.fa.pac
85d7f8991619c22bd892471e036b8069  reference/lambda_virus.fa.sa
1b5c6a505b5644c1813a9067eb221690  aln-pe.sam
057a61ed17bf57a3e140f682243bc4f8  aln-se.sam
9d34d16ee1e868b60c7f822e8463e90c  mem-pe.sam
a921380684ebfa28102caf2641ae9239  mem-se.sam
EOF

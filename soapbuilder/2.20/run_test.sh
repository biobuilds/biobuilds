#!/bin/bash

for d in reads reference; do
    cp -rv "${PREFIX}/share/mapper-test-data/${d}/" ${d}/
done

REFERENCE="lambda_virus"
2bwt-builder "reference/${REFERENCE}.fa"

md5sum -c - <<EOF
d41d8cd98f00b204e9800998ecf8427e  reference/lambda_virus.fa.index.amb
0245378a7b373e30a5f718d5ca97bfae  reference/lambda_virus.fa.index.ann
80df9e20ee3f679bee6efe5164898cab  reference/lambda_virus.fa.index.bwt
990f64fedb8014f04045073a97ead886  reference/lambda_virus.fa.index.fmv
b99bfc5e3c0025a45a62f76a37879441  reference/lambda_virus.fa.index.lkt
27c59f7f0708bb35ad99f502c2b33ab7  reference/lambda_virus.fa.index.pac
7208ebc998922629616bd8a0209374f0  reference/lambda_virus.fa.index.rev.bwt
89024f2f35abc36a733f0e9010c58d6a  reference/lambda_virus.fa.index.rev.fmv
22f5d038449d3ea360c563a4dd4a0bad  reference/lambda_virus.fa.index.rev.lkt
32cfe6ddcd46d5a39f75f94b2c1faf97  reference/lambda_virus.fa.index.rev.pac
723b453f875d97b77919990b466d42e2  reference/lambda_virus.fa.index.sa
d6390731b845cfa04ff474e5b4acb478  reference/lambda_virus.fa.index.sai
EOF

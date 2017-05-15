#!/bin/bash

set -o pipefail

tar xf test-data.tar.gz
abyss-pe k=25 name=test \
    in='test-data/reads1.fastq test-data/reads2.fastq'
abyss-fac test-unitigs.fa

md5sum -c - <<EOF
c1ed837dc43067c7a2086b6ab9353017  test-1.fa
15c0d400ca552f6d7c6e987156c8c376  test-2.fa
319274e8abac16c99805b62ec286f202  test-3.fa
7519e15a2056f7bf583674367873fb46  test-4.fa
d41d8cd98f00b204e9800998ecf8427e  test-5.fa
0df8e89fbdd8c4e5d7861d92b22949e8  test-6.fa
d41d8cd98f00b204e9800998ecf8427e  test-7.fa
99daea0526c096891f8a5494faa07fb2  test-8.fa
673ddcb39fbbf76c546556a49beead4c  test-bubbles.fa
0df8e89fbdd8c4e5d7861d92b22949e8  test-contigs.fa
0beb3c347fd6927067a8795e6c1d149e  test-indel.fa
99daea0526c096891f8a5494faa07fb2  test-scaffolds.fa
319274e8abac16c99805b62ec286f202  test-unitigs.fa
5061e4063c3a885917392299d4171c27  test-1.dot
bf709a7321045c11a2615ed3bf965591  test-2.dot
4550d59a0af02ae9d260b90183e0fbb4  test-3.dot
bd872119f37af2559b10298bcc894408  test-4.dot
bd872119f37af2559b10298bcc894408  test-5.dot
2c847d4a1dd4c0a91fa002365c6d97b3  test-6.dist.dot
a3eade1afc11890c1064bff83ae7db8f  test-6.dot
0df2adc17112fa8725f24cb79a50e88a  test-6.path.dot
a3eade1afc11890c1064bff83ae7db8f  test-7.dot
fe84352ca856a8d674b480a553c0393d  test-8.dot
a3eade1afc11890c1064bff83ae7db8f  test-contigs.dot
fe84352ca856a8d674b480a553c0393d  test-scaffolds.dot
EOF

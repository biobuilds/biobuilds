#!/bin/bash

# Write a "pinned" file to the environment's "conda-meta" directory to prevent
# accidental package upgrades or downgrades. This "enforces" the notion that a
# BioBuilds release is a reference environment that shouldn't be altered; users
# who want a customized environment should use the other conda tools instead.
[ -d "${PREFIX}/conda-meta" ] || mkdir -p "${PREFIX}/conda-meta"

cat >"${PREFIX}/conda-meta/pinned" <<EOF
# In particular, don't want these components to change versions, or
# applications in the environment could break in very strange and bad ways.
boost 1.54.0
python 2.7.11
numpy 1.10.4
scipy 0.17.0
r 3.2.2
perl 5.22.0 2

# Set of tools included in this BioBuilds release for all platforms
bamtools 2.4.0 1
bcftools 1.3.0 pl5.22.0_0
bedtools 2.25.0 0
bfast 0.7.0a 0
biopython 1.66 np110py27_0
blast 2.3.0 py27pl5.22.0_0
bowtie 1.1.2 py27_0
bowtie2 2.2.8 py27pl5.22.0_0
breakdancer 1.4.5 pl5.22.0_0
bwa 0.7.13 0
chimerascan 0.4.5a py27_0
clustalw 2.1 0
cufflinks 2.2.1 py27_2
delly 0.7.2 0
emboss 6.5.7 1
fasta 36.3.8c 0
fastqc 0.11.5 pl5.22.0_0
fastx-toolkit 0.0.14 pl5.22.0_0
freebayes 1.0.2 0
genomonfisher 0.1.1 py27_0
gnuplot 5.0.0 1
graphviz 2.38.0 bb1
hmmer 3.1b2 0
htseq 0.6.1 np110py27_0
htslib 1.3.0 0
igv 2.3.72 0
lofreq_star 2.1.2 py27_0
matplotlib 1.5.1 np110py27_0
mothur 1.36.1 1
mrbayes 3.2.6 0
muscle 3.8.31 0
oases 0.2.8 0
pandas 0.18.0 np110py27_0
perl-bioperl 1.6.924 pl5.22.0_0
phylip 3.696 0
picard 2.1.1 0
pindel 0.2.5b8 0
plink 1.07 0
pysam 0.8.4 py27_0
r-annotationdbi 1.32.0 r3.2.2_1
r-biobase 2.30.0 r3.2.2_0
r-bioc-base 3.2.012001 r3.2.2_0
r-biocgenerics 0.16.1 r3.2.2_0
r-biocinstaller 1.20.1 r3.2.2_0
r-bitops 1.0_6 r3.2.2_0
r-blockmodeling 0.1.8 r3.2.2_0
r-boot 1.3_17 r3.2.2_0
r-catools 1.17.1 r3.2.2_0
r-class 7.3_14 r3.2.2_0
r-cluster 2.0.3 r3.2.2_0
r-codetools 0.2_14 r3.2.2_0
r-crayon 1.3.1 r3.2.2_0
r-dbi 0.3.1 r3.2.2_0
r-digest 0.6.8 r3.2.2_0
r-ebseq 1.10.0 r3.2.2_0
r-foreign 0.8_66 r3.2.2_0
r-gdata 2.17.0 r3.2.2_0
r-gplots 2.17.0 r3.2.2_0
r-gtools 3.5.0 r3.2.2_0
r-iranges 2.4.3 r3.2.2_0
r-kernsmooth 2.23_15 r3.2.2_0
r-lattice 0.20_33 r3.2.2_0
r-mass 7.3_44 r3.2.2_0
r-matrix 1.2_2 r3.2.2_0
r-memoise 0.2.1 r3.2.2_0
r-mgcv 1.8_7 r3.2.2_0
r-nlme 3.1_122 r3.2.2_0
r-nnet 7.3_11 r3.2.2_0
r-praise 1.0.0 r3.2.2_0
r-rpart 4.1_10 r3.2.2_0
r-rsqlite 1.0.0 r3.2.2_0
r-s4vectors 0.8.3 r3.2.2_0
rsem 1.2.29 py27pl5.22.0r3.2.2_0
r-spatial 7.3_11 r3.2.2_0
r-survival 2.38_3 r3.2.2_0
r-testthat 0.11.0 r3.2.2_0
sailfish 0.9.0 0
samtools 1.3.0 py27pl5.22.0_0
scalpel 0.5.3 pl5.22.0_0
shrimp 2.2.3 0
snpeff 4.2 0
snpsift 4.2 0
soapaligner 2.20 0
soapbuilder 2.20 0
soapdenovo2 2.4.240 0
splazers 1.3.3 0
sqlite 3.9.2
star 2.5.1b 1
star-fusion 0.7.0 pl5.22.0_0
t-coffee 11.00.00_8cbe486 0
tabix 1.3.0 0
tassel 5.2.22 pl5.22.0_1
tmap 3.4.0 0
tophat 2.1.1 py27_0
trinity 2.2.0 py27pl5.22.0r3.2.2_0
variant_tools 2.7.0 py27_0
velvet 1.2.10 1
EOF

if [ `uname -s` == 'Linux' ]; then
    cat >>"${PREFIX}/conda-meta/pinned" <<EOF2
barracuda 0.7.107e 0
soap3-dp r177 2
allpathslg 52488 2
isaac 15.04.01 0
EOF2
fi

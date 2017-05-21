#!/bin/bash

REFERENCE="lambda_virus"
REF_BP="48500"      # Reference genome size (actually 48502-bp)

SEED=42

INS_SIZE=500
READ_LEN=100
N_READS=10000

cp -fv "${PREFIX}/share/mapper-test-data/reference/${REFERENCE}.fa" .

wgsim -S $SEED -A 0.05 \
    -e 0.005 -r 0.0001 -R 0.0 -X 0.0 \
    -d "$INS_SIZE" -1 "$READ_LEN" -2 "$READ_LEN" \
    -N "$N_READS" "${REFERENCE}.fa" "reads_1.fq" "reads_2.fq"

alpha=`echo | awk "{ printf \"%.2f\", 7.0 * ${REF_BP} / ${READ_LEN} / ${N_READS}; }"`
lighter -r reads_1.fq -r reads_2.fq \
    -k 17 ${REF_BP} ${alpha}


# Skipping checksum because our OS X and Linux builds generate different
# results, even when building using the "same" compiler (conda-supplied gcc
# 4.8.5) with no optimizations enabled ("-m64 -O0" passed as ${CXXFLAGS}).

#md5sum -c - <<EOF
#f8f5d185756b0953a6742485f9738e8a  reads_1.cor.fq
#d63013e0f2653b2d06a82890794ff577  reads_1.fq
#7fd1b7ab1799558517cbe69f1484ea54  reads_2.cor.fq
#ff3c217d2c81b5a18fe7e3ada4657b19  reads_2.fq
#EOF

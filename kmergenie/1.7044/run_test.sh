#!/bin/bash

REFERENCE="lambda_virus"

SEED=42
INS_SIZE=200
READ_LEN=75

cp -fv "${PREFIX}/share/mapper-test-data/reference/${REFERENCE}.fa" .

wgsim -S $SEED -A 0.05 \
    -e 0.0 -r 0.0001 -R 0.0 -X 0.0 \
    -d "$INS_SIZE" -1 "$READ_LEN" -2 "$READ_LEN" \
    -N 100000 "${REFERENCE}.fa" "reads_1.fq" "reads_2.fq"

kmergenie reads_1.fq

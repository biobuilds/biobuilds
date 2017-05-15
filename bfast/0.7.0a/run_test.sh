#!/bin/bash
set -e -x -u -o pipefail

REFNAME="lambda_virus"
READ_SET="reads_1"

print_step() {
    echo -e "\n----- ${1:-Doing something...} -----"
}

# Copy the data over to make things easier
for d in reads reference; do
    cp -rv "${PREFIX}/share/mapper-test-data/${d}/." ${d}/
done

print_step "Cleaning up previous run"
rm -f reference/${REFNAME}.fa.*

print_step "Creating reference genome"
bfast fasta2brg -f "reference/${REFNAME}.fa" -A 0

print_step "Indexing reference genome"
bfast index -f "reference/${REFNAME}.fa" -A 0 \
    -i 1 -m 111111111111111111 -w 12

print_step "Generating CALs for ${READ_SET}"
bfast match -f "reference/${REFNAME}.fa" -A 0 \
    -r "reads/${READ_SET}.fq" > "${READ_SET}.bmf"

print_step "Performing local alignments for ${READ_SET}"
bfast localalign -f "reference/${REFNAME}.fa" -A 0 \
    -m "${READ_SET}.bmf" > "${READ_SET}.baf"

print_step "Filtering alignments for ${READ_SET}"
bfast postprocess -f "reference/${REFNAME}.fa" -A 0 \
    -i "${READ_SET}.baf" -O 1 > "${READ_SET}.sam"

md5sum -c - <<EOF
07e0a323e5ffbd991138a737676a0bb1  reads_1.sam
EOF

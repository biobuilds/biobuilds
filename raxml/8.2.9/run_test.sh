#!/bin/bash

NTHREADS=2
SEED=12345

set -e -x

# Basic sanity check
raxml -h &>/dev/null

# Run through the tutorial commands
rm -f *.T[0-9]* binary.phy.reduced
tar -xf test_data.tar.bz2
raxml -T ${NTHREADS} -p ${SEED} -m BINGAMMA -s binary.phy -n T1 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m BINCAT -s binary.phy -n T2 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m BINGAMMA -s binary.phy -n T3 >/dev/null
#raxml -T ${NTHREADS} -p ${SEED} -m BINGAMMA -t startingTree.txt -s binary.phy -n T4 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m BINGAMMA -s binary.phy -# 20 -n T5 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRGAMMA -s dna.phy -# 20 -n T6 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m PROTGAMMAWAG -s protein.phy -# 20 -n T7 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m PROTGAMMAJTTF -s protein.phy -n T8 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m PROTCATJTTF -s protein.phy -n T9 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m MULTIGAMMA -s multiState.phy -n T10 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m MULTIGAMMA -s multiState.phy -K MK -n T11 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m MULTIGAMMA -s multiState.phy -K ORDERED -n T12 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRGAMMA -# 20 -s dna.phy -n T13 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -b ${SEED} -m GTRGAMMA -# 100 -s dna.phy -n T14 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRCAT -f b -t RAxML_bestTree.T13 -z RAxML_bootstrap.T14 -n T15 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRCAT -J STRICT -z RAxML_bootstrap.T14 -n T16 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRCAT -J MR -z RAxML_bootstrap.T14 -n T17 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRCAT -J MRE-z RAxML_bootstrap.T14 -n T18 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -x ${SEED} -m GTRGAMMA -# 100 -s dna.phy -n T19 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -x ${SEED} -f a -m GTRGAMMA -# 100 -s dna.phy -n T20 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRGAMMA -q simpleDNApartition.txt -s dna.phy -n T21 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -M -m GTRGAMMA -q simpleDNApartition.txt -s dna.phy -n T22 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRGAMMA -q dna12_3.partition.txt -s dna.phy -n T23 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRGAMMA -q dna_protein_partitions.txt -s dna_protein.phy -n T24 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m PROTGAMMAWAG -q dna_protein_partitions.txt -s dna_protein.phy -n T25 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -m GTRGAMMA -S secondaryStructure.txt -s dna.phy -n T26 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -r backboneConstraint.txt -m GTRGAMMA -s dna.phy -n T28 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -g multiConstraint.txt -m GTRGAMMA -s dna.phy -n T29 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -g monophylyConstraint.txt -m GTRGAMMA -s dna.phy -n T29.monophyly >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -g weirdMonophyly.txt -m GTRGAMMA -s dna.phy -n T29.weird_monophyly >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -o Mouse -m GTRGAMMA -s dna.phy -n T30 >/dev/null
raxml -T ${NTHREADS} -p ${SEED} -o Mouse,Rat -m GTRGAMMA -s dna.phy -n T31 >/dev/null

# Ideally, we'd run some other tool like `md5sum` to verify the uniformity of
# results across all our target platforms. However, due to the intricacies of
# floating-point operations, we can't do that right now, as we slightly
# different answers out in the last few decimal places. So for now, assume that
# if the above tests run, the compiled `raxml` binary is working as expected.

#(md5sum -c results.md5sum 2>&1 | grep -v ': OK$' && exit 1 || \
#    echo "All results as expected")

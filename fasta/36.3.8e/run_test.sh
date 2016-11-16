#!/bin/bash

# Conda test script for FASTA; based on the source test/test.sh script
# NOTE: These only test that the applications compile and run; they do *NOT*
#       verify that the outputs generated

set -e

# Test setup
[ -d "seq" ] && rm -rf seq
[ -d "results" ] && rm -rf results
tar -xzf test_data.tar.gz
mkdir results

# Run tests
echo "STARTING FASTA36 TESTS" `date` "on" `uname -a`
fasta36 -q seq/mmu_gstm1.prot seq/aa_test.lib > results/test_fasta_aa.out
fasta36 -q seq/mmu_gstm1.mrna seq/nt_test.lib > results/test_fasta_nt.out
fastx36 -q seq/mmu_gstm1.mrna seq/aa_test.lib > results/test_fastx.out
fasty36 -q seq/mmu_gstm1.mrna seq/aa_test.lib > results/test_fasty.out
fastx36 -q seq/mmu_gstm1.mrna_rc seq/aa_test.lib > results/test_fastx_rc.out
fasty36 -q seq/mmu_gstm1.mrna_rc seq/aa_test.lib > results/test_fasty_rc.out
ssearch36 -q -k 1000 -a seq/mmu_gstm1.prot seq/rno_gsta4.prot xurtg.aa > results/test_ssearch.out
ggsearch36 -q seq/mmu_gstm1.prot seq/aa_test.lib > results/test_ggsearch.out
glsearch36 -q seq/mmu_gstm1.prot seq/aa_test.lib > results/test_glsearch.out
tfastx36 -q -i seq/mmu_gstm1.prot seq/nt_test.lib > results/test_tfastx36.out
tfasty36 -q -i seq/mmu_gstm1.prot seq/nt_test.lib > results/test_tfasty36.out
fastf36 -q seq/m1r.aa seq/aa_test.lib > results/test_fastf.out
fasts36 -q seq/ngts.aa seq/aa_test.lib > results/test_fasts.out
fastm36 -q seq/ngts.aa seq/aa_test.lib > results/test_fastm.out
tfastf36 -q seq/m1r.aa seq/nt_test.lib > results/test_tfastf.out
tfasts36 -q seq/ngts.aa seq/nt_test.lib > results/test_tfasts.out
tfastm36 -q seq/ngts.aa seq/nt_test.lib > results/test_tfastm.out
lalign36 -q -k 1000 seq/mmu_gstm1.prot seq/mmu_gstm1.prot > results/test_lalign.out
lalign36 -q -k 1000 -s BL62 seq/mmu_gstm1.prot seq/mmu_gstm1.prot > results/test_lalign.out
echo "FINISHED FASTA36 TESTS" `date`

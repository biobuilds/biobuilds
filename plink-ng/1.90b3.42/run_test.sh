#!/bin/bash

set -e -x
set -o pipefail

SEED=1476885736

###  Based on upstream "test_setup.sh"  ###
plink-ng --seed ${SEED} --silent --dummy 513 1423 0.02 --out dummy_cc1
plink-ng --seed ${SEED} --silent --dummy 512 1234 0.04 --out dummy_cc2
plink-ng --seed ${SEED} --silent --dummy 387 1112 0.03 scalar-pheno --out dummy1
plink-ng --seed ${SEED} --silent --dummy 478 1111 0.05 scalar-pheno --out dummy2
plink-ng --seed ${SEED} --silent --dummy 3 9999 0.01 --out trio_tmp

cat >trio_tmp.fam <<EOF
fam1 dad 0 0 1 2
fam1 mom 0 0 2 1
fam1 son dad mom 1 1
EOF

plink-ng --seed ${SEED} --silent --bfile trio_tmp --geno 0.6 --make-bed --out trio
rm -f trio_tmp*

cat >set.txt <<EOF
1 10 20 set1
1 15 40 set2
EOF

cat >score.txt <<EOF
snp1 A 0.1
snp3 A 0.04
EOF


###  Based on upstream "tests.py"  ###
bfile_names=( 'dummy_cc1' 'dummy_cc2' 'dummy1' 'dummy2' 'trio' )
bfile_names_cc=( 'dummy_cc1' 'dummy_cc2' )
bfile_names_qt=( 'dummy1' 'dummy2' )
bfile_names_fam=( 'trio' )

for bfn in "${bfile_names[@]}"; do
    plink --bfile "${bfn}" --silent --nonfounders --max-maf 0.4999 --recode --out test1
    plink-ng --bfile "${bfn}" --silent --nonfounders --max-maf 0.4999 --recode --out test2
    diff -q test1.ped test2.ped
    diff -q test1.map test2.map

    plink --file test1 --silent --nonfounders --maf 0.04999 --write-snplist --out test1
    plink-ng --file test2 --silent --nonfounders --maf 0.04999 --write-snplist --out test2
    diff -q test1.snplist test2.snplist
done
echo -e '*** --file/--maf/--max-maf/--nonfounders/--recode/--write-snplist test passed. ***\n'

# --hwe takes case/control status into account, and VCF doesn't store that,
# so this test is quantitative-trait only
for bfn in "${bfile_names_qt[@]}"; do
    plink-ng --bfile "${bfn}" --silent --recode vcf --out test2
    plink --bfile "${bfn}" --silent --hwe 0.009999 --write-snplist --out test1
    plink-ng --vcf test2.vcf --silent --hwe 0.009999 --write-snplist --out test2
    diff -q test1.snplist test2.snplist
done
echo -e '*** --hwe/--recode vcf/--vcf test passed. ***\n'

for bfn in "${bfile_names[@]}"; do
    plink --bfile "${bfn}" --silent --nonfounders --max-maf 0.4999 --recode --transpose --out test1
    plink-ng --bfile "${bfn}" --silent --nonfounders --max-maf 0.4999 --recode transpose --out test2
    diff -q test1.tped test2.tped
    diff -q test1.tfam test2.tfam

    plink --tfile test1 --silent --missing --out test1
    plink-ng --tfile test2 --silent --missing --out test2
    diff -q test1.imiss test2.imiss
    diff -q test1.lmiss test2.lmiss
done
echo -e '*** --missing/--recode transpose/--tfile test passed. ***\n'

plink --bfile "${bfile_names_cc[0]}" --silent --bmerge "${bfile_names_cc[1]}.bed" "${bfile_names_cc[1]}.bim" "${bfile_names_cc[1]}.fam" --max-maf 0.4999 --make-bed --out test1
plink-ng --bfile "${bfile_names_cc[0]}" --silent --bmerge "${bfile_names_cc[1]}" --max-maf 0.4999 --make-bed --out test2
diff -q test1.bed test2.bed
diff -q test1.bim test2.bim
diff -q test1.bim test2.bim
echo -e '*** --bmerge/--make-bed test passed. ***\n'

rm -f test2.bim
plink-ng --bfile "${bfile_names_cc[0]}" --silent --bmerge "${bfile_names_cc[1]}" --max-maf 0.4999 --make-just-bim --out test2
diff -q test1.bim test2.bim
echo -e '*** --make-just-bim test passed. ***\n'

#m -f test2.fam
plink-ng --bfile "${bfile_names_cc[0]}" --silent --bmerge "${bfile_names_cc[1]}" --make-just-fam --out test2
diff -q test1.fam test2.fam
echo -e '*** --make-just-fam test passed. ***\n'

for bfn in "${bfile_names_cc[@]}"; do
    # force at least 14 to be missing out of 513...
    plink-ng --bfile "${bfn}" --silent --geno 0.06049 --max-maf 0.4999 --write-snplist --out test2
    plink --bfile "${bfn}" --silent --freq --extract test2.snplist --out test1
    plink-ng --bfile "${bfn}" --silent --freq --extract test2.snplist --out test2
    diff -q test1.frq test2.frq
done
echo -e '*** --extract/--freq/--geno test passed. ***\n'

for bfn in "${bfile_names_fam[@]}"; do
    plink --bfile "${bfn}" --silent --covar "${bfn}.fam" --covar-number 3 --filter-founders --write-covar --out test1
    plink-ng --bfile "${bfn}" --silent --covar "${bfn}.fam" --covar-number 3 --filter-founders --write-covar --out test2
    diff -q test1.cov test2.cov
done
echo -e '*** --covar/--covar-number/--filter-founders/--write-covar test passed. ***\n'

for bfn in "${bfile_names[@]}"; do
    plink --bfile "${bfn}" --silent --cluster --K 2 --out test1
    plink-ng --bfile "${bfn}" --silent --cluster only2 old-tiebreaks --K 2 --out "${bfn}"
    diff -q test1.cluster2 "${bfn}.cluster2"
    plink --bfile "${bfn}" --silent --within "${bfn}.cluster2" --filter-females --write-cluster --out test1
    plink-ng --bfile "${bfn}" --silent --within "${bfn}.cluster2" --filter-females --write-cluster --out test2
    diff -q test1.clst test2.clst
done
echo -e '*** --cluster/--filter-females/--within/--write-cluster test passed. ***\n'

for bfn in "${bfile_names[@]}"; do
    plink --bfile "${bfn}" --silent --make-set set.txt --write-set --out test1
    plink-ng --bfile "${bfn}" --silent --make-set set.txt --write-set --out test2
    diff -q test1.set test2.set
    plink --bfile "${bfn}" --silent --make-set set.txt --set-table --out test1
    plink-ng --bfile "${bfn}" --silent --set test2.set --set-table --out test2
    # PLINK 1.07 generates a .set.table file with a double-tab after the
    # third column, which we deliberately don't replicate.  Remove it and
    # the header row (which doesn't have the double-tab) before diffing.
    tail -n +2 test1.set.table | cut -f 1-3,5- > test1.set.table2
    tail -n +2 test2.set.table > test2.set.table2
    diff -q test1.set.table2 test2.set.table2
done
echo -e '*** --make-set/--set/--set-table/--write-set test passed. ***\n'

plink-ng --bfile "${bfile_names_cc[1]}" --silent --recode --out test2
plink-ng --bfile "${bfile_names_cc[0]}" --silent --merge test2 --max-maf 0.4999 --make-bed --out test2
diff -q test1.bed test2.bed
diff -q test1.bim test2.bim
diff -q test1.bim test2.bim
echo -e '*** --merge test passed. ***\n'

echo "${bfile_names_cc[0]}.bed" "${bfile_names_cc[0]}.bim" "${bfile_names_cc[0]}.fam" > merge_list.txt
echo "${bfile_names_cc[1]}.bed" "${bfile_names_cc[1]}.bim" "${bfile_names_cc[1]}.fam" >> merge_list.txt
plink-ng --merge-list merge_list.txt --silent --max-maf 0.4999 --make-bed --out test2
diff -q test1.bed test2.bed
diff -q test1.bim test2.bim
diff -q test1.bim test2.bim
rm -f merge_list.txt
echo -e '*** --merge-list test passed. ***\n'

for bfn in "${bfile_names_cc[@]}"; do
    # diff error likely at MAF = 0.4875 due to rounding
    plink --bfile "${bfn}" --silent --flip-scan --mind 0.05399 --maf 0.4876 --max-maf 0.4999 --out test1
    plink-ng --bfile "${bfn}" --silent --flip-scan --mind 0.05399 --maf 0.4876 --max-maf 0.4999 --out test2
    diff -q test1.flipscan test2.flipscan
done
echo -e '*** --flip-scan/--mind test passed. ***\n'


# don't bother with --test-mishap for now due to EM phasing algorithm
# change

for bfn in "${bfile_names_cc[@]}"; do
    # force at least 14 to be missing out of 513...
    plink-ng --bfile "${bfn}" --silent --geno 0.0254 --write-snplist --out test1
    # ...but no more than 31 out of 512.

    # --hardy + --geno order of operations has changed, for good reason.
    plink-ng --bfile "${bfn}" --silent --exclude test1.snplist --geno 0.06049 --write-snplist --out test2

    plink --bfile "${bfn}" --silent --extract test2.snplist --hardy --out test1
    plink-ng --bfile "${bfn}" --silent --extract test2.snplist --hardy --out test2
    # skip column 8 due to likelihood of floating point error
    # note that leading space(s) cause it to be column 9 after tr
    tr -s ' ' $'\t' < test1.hwe | cut -f 1-8,10 > test1.hwe2
    tr -s ' ' $'\t' < test2.hwe | cut -f 1-8,10 > test2.hwe2
    diff -q test1.hwe2 test2.hwe2
done
echo -e '*** --exclude/--hardy test passed. ***\n'

for bfn in "${bfile_names_fam[@]}"; do
    plink --bfile "${bfn}" --silent --mendel --out test1
    plink-ng --bfile "${bfn}" --silent --mendel --out test2
    diff -q test1.mendel test2.mendel
    diff -q test1.imendel test2.imendel
    diff -q test1.fmendel test2.fmendel
    diff -q test1.lmendel test2.lmendel
done
echo -e '*** --mendel test passed. ***\n'

for bfn in "${bfile_names[@]}"; do
    plink-ng --bfile "${bfn}" --silent --recode oxford --out test2
    plink --bfile "${bfn}" --silent --het --nonfounders --out test1
    plink-ng --data test2 --silent --het --out test2
    diff -q test1.het test2.het
done
echo -e '*** --data/--het/--recode oxford test passed. ***\n'

for bfn in "${bfile_names_cc[@]}"; do
    rm -f test1.bim.tmp
    sed 's/^1/23/' "${bfn}.bim" > test1.bim.tmp
    plink-ng --bed "${bfn}.bed" --bim test1.bim.tmp --fam "${bfn}.fam" --silent --freq --out test1
    plink --bed "${bfn}.bed" --bim test1.bim.tmp --fam "${bfn}.fam" --silent --read-freq test1.frq --check-sex --out test1
    plink-ng --bed "${bfn}.bed" --bim test1.bim.tmp --fam "${bfn}.fam" --silent --read-freq test1.frq --check-sex --out test2
    diff -q test1.sexcheck test2.sexcheck
    plink --bed "${bfn}.bed" --bim test1.bim.tmp --fam "${bfn}.fam" --silent --read-freq test1.frq --maf 0.4876 --max-maf 0.4999 --impute-sex --make-bed --out test1
    plink-ng --bed "${bfn}.bed" --bim test1.bim.tmp --fam "${bfn}.fam" --silent --read-freq test1.frq --maf 0.4876 --max-maf 0.4999 --impute-sex --make-bed --out test2
    diff -q test1.sexcheck test2.sexcheck
    diff -q test1.bed test2.bed
    diff -q test1.bim test2.bim
    diff -q test1.fam test2.fam
done
echo -e '*** --check-sex/--impute-sex/--read-freq test passed. ***\n'

# Skip --indep-pairwise for now since harmless minor differences are
# expected.

# floating-point error is more likely to affect --r, so we just test --r2
for bfn in "${bfile_names[@]}"; do
    plink --bfile "${bfn}" --silent --r2 --out test1
    plink-ng --bfile "${bfn}" --silent --r2 --out test2
    diff -q test1.ld test2.ld
done
echo -e '*** --r2 test passed. ***\n'

for bfn in "${bfile_names[@]}"; do
    plink-ng --bfile "${bfn}" --silent --make-set set.txt --write-set --out test1
    plink --bfile "${bfn}" --silent --set test1.set --gene set2 --show-tags all --tag-r2 0.031 --out test1
    plink-ng --bfile "${bfn}" --silent --make-set set.txt --gene set2 --show-tags all --tag-r2 0.031 --out test2
    # ignore column 7 since we changed the interval length definition
    sed 's/^[[:space:]]*//g' test1.tags.list | tr -s ' ' $'\t' | cut -f 1-6,8 > test1.tags.list2
    sed 's/^[[:space:]]*//g' test2.tags.list | tr -s ' ' $'\t' | cut -f 1-6,8 > test2.tags.list2
    diff -q test1.tags.list2 test2.tags.list2
done
echo -e '*** --gene/--show-tags test passed. ***\n'

# skip --blocks for now since test files lack the necessary LD

for bfn in "${bfile_names[@]}"; do
    plink --bfile "${bfn}" --silent --cluster --distance-matrix --out test1
    plink-ng --bfile "${bfn}" --silent --distance-matrix --out test2
    diff -q test1.mdist test2.mdist
done
echo -e '*** --distance-matrix test passed. ***\n'

for bfn in "${bfile_names[@]}"; do
    plink --bfile "${bfn}" --silent --genome --out test1
    plink-ng --bfile "${bfn}" --silent --genome --out test2
    diff -q test1.genome test2.genome
done
echo -e '*** --genome test passed. ***\n'

for bfn in "${bfile_names[@]}"; do
    plink --bfile "${bfn}" --silent --homozyg --out test1
    plink-ng --bfile "${bfn}" --silent --homozyg subtract-1-from-lengths --out test2
    diff -q test1.hom test2.hom
done
echo -e '*** --homozyg test passed. ***\n'

# skip --neighbour test for now due to likelihood of ties.  (Caught a
# command-line parsing bug when trying to write that test, though.)

for bfn in "${bfile_names_cc[@]}"; do
    plink --bfile "${bfn}" --silent --assoc --max-maf 0.4999 --out test1
    plink-ng --bfile "${bfn}" --silent --assoc --max-maf 0.4999 --out test2
    # remove columns 5/6/8 due to likely rounding differences (6/7/9 after
    # leading space)
    tr -s ' ' $'\t' < test1.assoc | cut -f 1-5,8 > test1.assoc2
    tr -s ' ' $'\t' < test2.assoc | cut -f 1-5,8 > test2.assoc2
    diff -q test1.assoc2 test2.assoc2
done
echo -e '*** Case/control --assoc test passed. ***\n'

for bfn in "${bfile_names_qt[@]}"; do
    plink --bfile "${bfn}" --silent --assoc --max-maf 0.4999 --out test1
    plink-ng --bfile "${bfn}" --silent --assoc --max-maf 0.4999 --out test2
    diff -q test1.qassoc test2.qassoc
done
echo -e '*** QT --assoc test passed. ***\n'

for bfn in "${bfile_names_cc[@]}"; do
    plink --bfile "${bfn}" --silent --max-maf 0.4999 --model --out test1
    plink-ng --bfile "${bfn}" --silent --max-maf 0.4999 --model --out test2
    diff -q test1.model test2.model
done
echo -e '*** --model test passed. ***\n'

for bfn in "${bfile_names_cc[@]}"; do
    plink --bfile "${bfn}" --silent --within "${bfn}.cluster2" --max-maf 0.4999 --bd --out test1
    plink-ng --bfile "${bfn}" --silent --within "${bfn}.cluster2" --max-maf 0.4999 --bd --out test2
    diff -q test1.cmh test2.cmh
done
echo -e '*** --bd test passed. ***\n'

# --mh2 output format has been changed, so we skip that.

for bfn in "${bfile_names_cc[@]}"; do
    plink --bfile "${bfn}" --silent --within "${bfn}.cluster2" --max-maf 0.4999 --homog --out test1
    plink-ng --bfile "${bfn}" --silent --within "${bfn}.cluster2" --max-maf 0.4999 --homog --out test2
    diff -q test1.homog test2.homog
done
echo -e '*** --homog test passed. ***\n'

for bfn in "${bfile_names_qt[@]}"; do
    plink-ng --bfile "${bfn}" --silent --cluster --K 3 --out test1
    plink --bfile "${bfn}" --silent --gxe --covar test1.cluster2 --max-maf 0.4999 --out test1
    plink-ng --bfile "${bfn}" --silent --gxe --covar test1.cluster2 --max-maf 0.4999 --out test2
    diff -q test1.qassoc.gxe test2.qassoc.gxe
done
echo -e '*** --gxe test passed. ***\n'

# can't use qt[1] as covar file since it probably used the same random seed
# and hence has the same phenotypes as qt[0]
plink --bfile "${bfile_names_qt[0]}" --silent --adjust --linear --covar "${bfile_names_cc[0]}.fam" --covar-number 4 --out test1
plink-ng --bfile "${bfile_names_qt[0]}" --silent --adjust --linear --covar "${bfile_names_cc[0]}.fam" --covar-number 4 --out test2
diff -q test1.assoc.linear test2.assoc.linear
diff -q test1.assoc.linear.adjusted test2.assoc.linear.adjusted
echo -e '*** --adjust/--linear test passed. ***\n'

# skip --logistic for now due to internal use of single precision floats
for bfn in "${bfile_names_qt[@]}"; do
    plink-ng --bfile "${bfn}" --silent --recode oxford --out test1
    plink --silent --dosage test1.gen noheader skip0=1 skip1=1 format=3 --fam "${bfn}.fam" --covar "${bfile_names_cc[0]}.fam" --covar-number 4 --out test1
    plink-ng --silent --dosage test1.gen noheader skip0=1 skip1=1 format=3 --fam "${bfn}.fam" --covar "${bfile_names_cc[0]}.fam" --covar-number 4 --out test2
    diff -q test1.assoc.dosage test2.assoc.dosage
done
echo -e '*** --dosage test passed. ***\n'

# [0] may or may not have variants with zero missing calls, which
# complicates things
plink --bfile "${bfile_names_cc[1]}" --silent --test-missing --out test1
plink-ng --bfile "${bfile_names_cc[1]}" --silent --test-missing --out test2
diff -q test1.missing test2.missing
echo -e '*** --test-missing test passed. ***\n'

for bfn in "${bfile_names_fam[@]}"; do
    plink --bfile "${bfn}" --silent --tdt --out test1
    plink-ng --bfile "${bfn}" --silent --tdt --out test2
    diff -q test1.tdt test2.tdt
done
echo -e '*** --tdt test passed. ***\n'

# skip --qfam for now since there's no QT test file with family info

for bfn in "${bfile_names_qt[@]}"; do
    plink-ng --bfile "${bfn}" --silent --linear --out test1
    plink --silent --annotate test1.assoc.linear ranges=set.txt --out test1
    plink-ng --silent --annotate test1.assoc.linear ranges=set.txt --out test2
    diff -q test1.annot test2.annot
done
echo -e '*** --annotate test passed. ***\n'

# skip --clump for now due to lack of LD

# skip --gene-report for now due to format changes

for bfn in "${bfile_names_cc[@]}"; do
    plink --bfile "${bfn}" --silent --fast-epistasis --out test1
    plink-ng --bfile "${bfn}" --silent --fast-epistasis no-ueki --parallel 1 2 --out test2
    plink-ng --bfile "${bfn}" --silent --fast-epistasis no-ueki --parallel 2 2 --out test2
    rm -f test2.epi.cc test2.epi.cc.summary
    cat test2.epi.cc.1 test2.epi.cc.2 > test2.epi.cc
    plink-ng --epistasis-summary-merge test2.epi.cc 2 --silent --out test2
    diff -q test1.epi.cc test2.epi.cc
    # remove column 6 (7 after leading spaces) due to floating point error
    tr -s ' ' $'\t' < test1.epi.cc.summary | cut -f 1-6,8- > test1.epi.cc.summary2
    tr -s ' ' $'\t' < test2.epi.cc.summary | cut -f 1-6,8- > test2.epi.cc.summary2
    diff -q test1.epi.cc.summary2 test2.epi.cc.summary2
done
echo -e '*** --epistasis-summary-merge/--fast-epistasis/--parallel test passed. ***\n'

# skip --twolocus due to format change

for bfn in "${bfile_names_qt[@]}"; do
    plink --bfile "${bfn}" --silent --score score.txt --out test1
    plink-ng --bfile "${bfn}" --silent --score score.txt --out test2
    diff -q test1.profile test2.profile
done
echo -e '*** --score test passed. ***\n'


echo -e '*** All tests passed. ***\n'
#rm -f test1.*
#rm -f test2.*


#--------------------------------------------------------------------------
# Ideally, we'd use 'md5sum' or some other tool to verify that 'plink-ng'
# produces the same results on all supported platforms. Unfortunately, the
# OS X and Linux versions currently produce different results for the
# following files:
#
#   test1.cluster1
#   test1.cluster2
#   test1.cluster3
#   test1.qassoc.gxe
#   test2.qassoc.gxe
#
#--------------------------------------------------------------------------

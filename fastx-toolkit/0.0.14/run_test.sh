#!/bin/bash
: ${PREFIX:=${CONDA_PREFIX}}
find . -type f ! -name run_test.sh ! -name test-data.tar.bz2 | xargs rm -f

set -e -x -u -o pipefail
tar -xf test-data.tar.bz2

fasta_formatter -i fasta_formatter1.fasta -o fasta_formatter1.out -w 0
fasta_formatter -i fasta_formatter1.fasta -o fasta_formatter2.out -w 60
fasta_nucleotide_changer -v -i fasta_nuc_changer1.fasta -o fasta_nuc_changer1.out -r
fasta_nucleotide_changer -v -i fasta_nuc_changer2.fasta -o fasta_nuc_changer2.out -d
fastq_masker -v -i fastq_masker.fastq -o fastq_masker.out -Q 64 -q 29 -r x
fastq_quality_converter -v -i fastq_qual_conv1.fastq -o fastq_qual_conv1.out -Q 64 -n
fastq_quality_converter -v -i fastq_qual_conv1.fastq -o fastq_qual_conv1a.out -Q 64 -a
fastq_quality_converter -v -i fastq_qual_conv2.fastq -o fastq_qual_conv2.out -Q 64 -a
fastq_quality_converter -v -i fastq_qual_conv2.fastq -o fastq_qual_conv2n.out -Q 64 -n
fastq_quality_filter -v -i fastq_qual_filter1.fastq -o fastq_qual_filter1a.out -Q 64 -q 33 -p 100
fastq_quality_filter -v -i fastq_qual_filter1.fastq -o fastq_qual_filter1b.out -Q 64 -q 20 -p 80
fastq_quality_trimmer -v -i fastq_quality_trimmer.fastq -o fastq_quality_trimmer.out -Q 64 -t 30 -l 16
fastq_to_fasta -v -i fastq_to_fasta1.fastq -o fastq_to_fasta1a.out
fastq_to_fasta -v -i fastq_to_fasta1.fastq -o fastq_to_fasta1b.out -r -n
fastx_artifacts_filter -v -i fastx_artifacts1.fasta -o fastx_artifacts1.out -Q 64
fastx_artifacts_filter -v -i fastx_artifacts2.fastq -o fastx_artifacts2.out -Q 33
fastx_barcode_splitter.pl --bcfile fastx_barcode_splitter1.txt \
    --prefix 'fastx_barcode_splitter1__' --suffix '.txt' \
    --mismatches 2 --partial 0 --bol < fastx_barcode_splitter1.fastq
fastx_clipper -v -i fastx_clipper1.fastq -o fastx_clipper1a.out -Q 64 -l 15 -a CAATTGGTTAATCCCCCTATATA -d 0 -n -c
fastx_collapser -v -i fasta_collapser1.fasta -o fasta_collapser1.out
fastx_quality_stats -v -i fastq_stats1.fastq -o fastq_stats1.out -Q 64
fastx_renamer -v -i fastx_renamer1.fastq -o fastx_renamer1.out -Q 64 -n SEQ
fastx_reverse_complement -v -i fastx_rev_comp1.fasta -o fastx_reverse_complement1.out
fastx_reverse_complement -v -i fastx_rev_comp2.fastq -o fastx_reverse_complement2.out
fastx_trimmer -v -i fastx_trimmer1.fasta -o fastx_trimmer1.out -f 5 -l 36
fastx_trimmer -v -i fastx_trimmer2.fastq -o fastx_trimmer2.out -f 1 -l 27
fastx_trimmer -v -i fastx_trimmer_from_end1.fasta -o fastx_trimmer_from_end1.out -t 2 -m 16
fastx_uncollapser -v -i fasta_uncollapser1.fasta -o fasta_uncollapser1.out
fastx_uncollapser -v -i fastx_seqid_uncollapse1.psl -o fastx_seqid_uncollapse1.out -c 10

fasta_clipping_histogram.pl fasta_formatter1.fasta fasta_formatter1.png
fastx_nucleotide_distribution_graph.sh -i fastq_stats1.out -o fastx_nucleotide_dist_graph.png

# BUG: looks for "cycle" instead of "column" to sanity check input
#fastx_nucleotide_distribution_line_graph.sh -i fastq_stats1.out -o fastx_nucleotide_dist_line_graph.png

# No test data available for this program, so just run it
fastq_quality_boxplot_graph.sh -h

md5sum -c - <<EOF
7875ff2b4a6aeae68376fa594695de25  fasta_collapser1.out
2af092b3b4fc3008ebd93f656612afa4  fasta_formatter1.out
cf9a7557a86cef3e47be733a8a928d3a  fasta_formatter2.out
b13ad28478a718c66456d292c08c2dd5  fasta_nuc_changer1.out
15bdf7d07e14b62ecb00444dd44b6566  fasta_nuc_changer2.out
3d5beb74e085df054d272ca2127eab22  fasta_uncollapser1.out
9545a707491ff0b7782897c8d562f63a  fastq_masker.out
bd8a2b989fc509b808d996e94d141ffd  fastq_qual_conv1.out
323e0745302352be733336ef4530ab2f  fastq_qual_conv1a.out
aaa777c7342afc9084d90481539c19db  fastq_qual_conv2.out
804fc22b4dfb81f009b43a15f237c36a  fastq_qual_conv2n.out
97989fc3ede0a83a43008068738ea489  fastq_qual_filter1a.out
fbe36229e2cc8ccdf5c27b041201edb3  fastq_qual_filter1b.out
5173e32392286a05e1317387cc0d567e  fastq_quality_trimmer.out
241ab6cd2531a81a8dca07293439c3cc  fastq_stats1.out
3d01c0020a69749f70f8fb538ef7343f  fastq_to_fasta1a.out
cfa21ee5c50ab1b4ea1794536e834487  fastq_to_fasta1b.out
6e8abdeaf2a6add087de30af25fa53d3  fastx_artifacts1.out
8b172bd894ea32d458320047e696af28  fastx_artifacts2.out
955f32b53f2d50f1bc6e881e3da69fe7  fastx_barcode_splitter1__BC1.txt
9acd5da3ee7da7465f6a8c58503aae45  fastx_barcode_splitter1__BC2.txt
6c05ee8fae097b0f7b7ec228074a8da3  fastx_barcode_splitter1__BC3.txt
771d8f6c2d8f50e26c1db1d7560cc02e  fastx_barcode_splitter1__BC4.txt
f49eeb1d0a2d74409f6bad6261bc74be  fastx_barcode_splitter1__unmatched.txt
4d6d4adfc8f9fc17cac80b702b2b93f6  fastx_clipper1a.out
3d064bf94efd79ed2e299bb8b7fc7ca4  fastx_renamer1.out
fded2b48880ac23078dcadb3a53c9af8  fastx_reverse_complement1.out
7dfac96d4a5fd283f5d354ecede2d0f6  fastx_reverse_complement2.out
24785b235049b16bcf8df7fe1d8a03d4  fastx_seqid_uncollapse1.out
b5ace17157a105eb3388aff61bd222e6  fastx_trimmer1.out
d6d81a3750dc46bb8e58d4130c9cba30  fastx_trimmer2.out
6cce6b5a41d22802a38e0b5002b696f7  fastx_trimmer_from_end1.out
EOF

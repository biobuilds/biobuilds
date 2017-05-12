#!/bin/bash

REFERENCE="lambda_virus"
CONF="asm.conf"

SEED=42
INS_SIZE=200
READ_LEN=75

cp -fv "${PREFIX}/share/mapper-test-data/reference/${REFERENCE}.fa" .

wgsim -S $SEED -A 0.05 \
    -e 0.0 -r 0.0001 -R 0.0 -X 0.0 \
    -d "$INS_SIZE" -1 "$READ_LEN" -2 "$READ_LEN" \
    -N 500000 "${REFERENCE}.fa" "reads_1.fq" "reads_2.fq"

cat <<EOF | tee "$CONF"
max_rd_len = 100
[LIB]
avg_ins=${INS_SIZE}
asm_flags=3
rd_len_cutoff=50
rank=1
pair_num_cutoff=3
map_len=32
q1=reads_1.fq
q2=reads_2.fq
EOF

SOAPdenovo-63mer  all -s "$CONF" -o "test-63mer"  -K 23
SOAPdenovo-127mer all -s "$CONF" -o "test-127mer" -K 31

md5sum -c - <<EOF
6adfa1ec3c43cb18ca9170ca5252bc20  asm.conf
4b93a7b4726f333e8bb5e2b371478e93  reads_1.fq
2d47f2926d3722a1b8b5c179c915ff0a  reads_2.fq
10abd31ea287a925f16028bb859f9181  test-127mer.Arc
d41d8cd98f00b204e9800998ecf8427e  test-127mer.bubbleInScaff
bf9753baddb74df73419c6a8dc671f4f  test-127mer.contig
8f86bd2cb976401c1d6c1250f8066355  test-127mer.ContigIndex
33a2044047750ff1fa0b00ca12d3b8c9  test-127mer.contigPosInscaff
3c6e58ed27819ebebe5c4207b319af69  test-127mer.edge.gz
d41d8cd98f00b204e9800998ecf8427e  test-127mer.gapSeq
a8934ab5f0360de568279b258955959c  test-127mer.kmerFreq
f0ea2eade6beeb2f093a8535d942a75a  test-127mer.links
fedefbaa10e6bb0b714f4794679590ef  test-127mer.newContigIndex
b8f659a362a65abcf2959a8af0f903cd  test-127mer.peGrads
c389913bd819f487aa97a3e4cbd9a323  test-127mer.preArc
0b9e7dbce226ab9ec27f19fbf2d35661  test-127mer.preGraphBasic
4e290f84f6adada81ba680b153b73151  test-127mer.readInGap.gz
d6c6f1573ec78d7167b7df1b99a0b8e0  test-127mer.readOnContig.gz
fa51a9a1ff806306e1e2fc2ee0bed48d  test-127mer.scaf
834ffe1d6d9d52e117b1faa60cdcccba  test-127mer.scaf_gap
bc8a4b6b547e17dc2f64f419e320fd0e  test-127mer.scafSeq
1448372f58b2614fd95136dc93379daa  test-127mer.scafStatistics
1a5b3bdd5eba545d22463981c0132f30  test-127mer.updated.edge
2393ae09991a010b992f8b977303c503  test-127mer.vertex
40da4e492df30ae8db4024d8a40c3594  test-63mer.Arc
d41d8cd98f00b204e9800998ecf8427e  test-63mer.bubbleInScaff
b77d3c295029a3b719643f0eaa9d2385  test-63mer.contig
64718c81807eb97ce49d43ac64bb7925  test-63mer.ContigIndex
4c64940a2a4263a039f64861b5b8879b  test-63mer.contigPosInscaff
cb24881df1424f87e693436691b5f9b6  test-63mer.edge.gz
d41d8cd98f00b204e9800998ecf8427e  test-63mer.gapSeq
a14a46ed9360332f88eb44d3166bd673  test-63mer.kmerFreq
1c5d4f8242ec96dccc10795b835052d0  test-63mer.links
97396d3a431a7279d5039e5f8c5b97bf  test-63mer.newContigIndex
b8f659a362a65abcf2959a8af0f903cd  test-63mer.peGrads
302111512d3bd13ac6f6f4b94e2d55c2  test-63mer.preArc
8a17ba4be29f963b4af85a4f11d4958e  test-63mer.preGraphBasic
a0849a700c832d12efc65fe6f40187ae  test-63mer.readInGap.gz
8b042ff232c499a30b179aa067aa8e0c  test-63mer.readOnContig.gz
ce7e8c1809b7b7e5a04ffb46c199d6e1  test-63mer.scaf
673cf63ddb3d23cd05295413228ff18c  test-63mer.scaf_gap
0c154c880188534d70184cdf552d3d45  test-63mer.scafSeq
4dcc002fc1a2e3a3ee00e47b213c9e09  test-63mer.scafStatistics
a8eac88ee238900fb1b1ad897e993c73  test-63mer.updated.edge
b58cf2761acae25452b2d0fa6a6453b5  test-63mer.vertex
EOF

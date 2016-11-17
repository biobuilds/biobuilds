#!/bin/bash
set -e -x -u

N_READS=10000

abort() {
    echo "FATAL: ${1:-Unknown error}" >&2
    exit 1
}

# Make sure required tools are available
command -v bwa >/dev/null || abort "'bwa' executable not found!"
command -v samtools >/dev/null || abort "'samtools' executable not found!"
command -v fisher >/dev/null || abort "'fisher' executable not found!"

samtools_ver=$(samtools 2>&1 | grep '^Version' | awk '{print $2;}')
set -o pipefail

# Set up the directory structure
for name in reference reads alignments ; do
    [ -d $name ] || mkdir $name
done

rm -f reference/*.fa.* reads/*sim*.fq alignments/*sim*.{sam,bam} *sim*.pileup
rm -f fisher-*

# Copy and index the reference genome
REF="reference/lambda_virus.fa"
cp -fv "${PREFIX}/share/mapper-test-data/reference/lambda_virus.fa" "$REF"
bwa index "$REF" 2>/dev/null

ref_base_fn=$(basename "$REF" | cut -d. -f1)
for i in {1..2}; do
    echo ""
    base_fn="${ref_base_fn}_sim${i}"
    r1="${base_fn}_1.fq"
    r2="${base_fn}_2.fq"
    sam="${base_fn}-bwa.sam"
    bam="${sam/.sam/.bam}"

    wgsim -S ${i} -N ${N_READS} -R 0.0 -X 0.0 -r 0.001 \
        "$REF" "reads/$r1" "reads/$r2" >/dev/null
    awk "BEGIN{n=0;}(NR%4==1){print \"@r${i}_\"n\"/1\"; n=n+1; next}; \$0" \
        < "reads/$r1" > tmp.1
    mv tmp.1 "reads/$r1"
    awk "BEGIN{n=0;}(NR%4==1){print \"@r${i}_\"n\"/2\"; n=n+1; next}; \$0" \
        < "reads/$r2" > tmp.2
    mv tmp.2 "reads/$r2"

    bwa mem "$REF" "reads/$r1" "reads/$r2" > "alignments/${sam}" 2>/dev/null

    rm -f "alignments/${bam}"
    if [[ "$samtools_ver" == "1.3"* ]]; then
        samtools view -b -T "${REF}" "alignments/${sam}" | \
            samtools sort -o "alignments/${bam}" -
    else
        samtools view -b -T "${REF}" "alignments/${sam}" > tmp.bam
        samtools sort tmp.bam "alignments/${sam/.sam}"
        rm -f tmp.bam
    fi

    rm -f "${base_fn}.pileup"
    samtools mpileup -q 30 -BQ 0 -d 10000000 \
        -f "$REF" "alignments/${bam}" \
        > "${base_fn}.pileup"

    fisher single -r "$REF" -s samtools \
        -1 "alignments/${bam}" \
        -o "fisher-s-${base_fn}.out"
done

fisher comparison -r "$REF" -s samtools \
    -1 "alignments/${ref_base_fn}_sim1-bwa.bam" \
    -2 "alignments/${ref_base_fn}_sim2-bwa.bam" \
    -o "fisher-c-${ref_base_fn}.out"

echo -e ""
md5sum -c - 2>/dev/null <<'EOF'
4d83416555fdddbc3506d2db62f97732  reads/lambda_virus_sim1_1.fq
a5b8a18d2ea78cc13ff5a15358019e2b  reads/lambda_virus_sim1_2.fq
e09242f23d781398c026247a09bf5659  reads/lambda_virus_sim2_1.fq
5432ffbe19a315c55926dd34efff9017  reads/lambda_virus_sim2_2.fq
d106ee4c0f0aa2665330d7e6711e117a  alignments/lambda_virus_sim1-bwa.bam
71f9606c5822a739998912cb0fa42a36  alignments/lambda_virus_sim1-bwa.sam
89d4814b505494185d7004b9d6a6a95a  alignments/lambda_virus_sim2-bwa.bam
d24af567c331a2483defeefe6a4fd5ed  alignments/lambda_virus_sim2-bwa.sam
d9d9de07655993e8434ed708e179fb56  lambda_virus_sim1.pileup
9046a9ab01ac3b247ebb9a71a5392b22  lambda_virus_sim2.pileup
926058ee8d588fdb298fa313acc1ac79  fisher-c-lambda_virus.out
e0a849644a151d0ac457b72f578a0ae1  fisher-s-lambda_virus_sim1.out
aaf20eae2de2765f6675cc0a4eb819bb  fisher-s-lambda_virus_sim2.out
EOF

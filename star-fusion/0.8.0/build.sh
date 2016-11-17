#!/bin/bash

set -o pipefail

# Replace @@prefix@@ stub with actual prefix so conda can works its
# path-munging magic when the package is installed.
cd "${SRC_DIR}"
for f in $(find . -type f | xargs egrep -Il "@@prefix@@"); do
    echo "Fixing @@prefix for '$f'"
    sed "s,@@prefix@@,${PREFIX},g;" < "$f" > tmpfile
    mv tmpfile "$f"
done

# Install process is basically just copying things into the right directories
install -m 0755 -d \
    "${PREFIX}/bin" \
    "${PREFIX}/share/star-fusion/PerlLib" \
    "${PREFIX}/share/star-fusion/util" \
    "${PREFIX}/share/fusion-filter/lib" \
    "${PREFIX}/share/fusion-filter/util" \
    "${PREFIX}/share/fusion-filter/util/paralog_clustering_util"

install -m 0755 \
    STAR-Fusion \
    FusionFilter/blast_and_promiscuity_filter.pl \
    FusionFilter/prep_genome_lib.pl \
    "${PREFIX}/bin"

install -m 0755 PerlLib/* "${PREFIX}/share/star-fusion/PerlLib"
install -m 0755 util/* "${PREFIX}/share/star-fusion/util"
install -m 0755 FusionFilter/lib/* "${PREFIX}/share/fusion-filter/lib"
install -m 0755 FusionFilter/util/*.pl "${PREFIX}/share/fusion-filter/util"
install -m 0755 FusionFilter/util/paralog_clustering_util/*.pl "${PREFIX}/share/fusion-filter/util/paralog_clustering_util"

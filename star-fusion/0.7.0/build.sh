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
mkdir -p "${PREFIX}/bin" \
    "${PREFIX}/share/star-fusion/lib" "${PREFIX}/share/star-fusion/util" \
    "${PREFIX}/share/fusion-filter/lib" "${PREFIX}/share/fusion-filter/util"

install -m 755 STAR-Fusion \
    FusionFilter/blast_and_promiscuity_filter.pl \
    FusionFilter/prep_genome_lib.pl \
    "${PREFIX}/bin"

install -m 755 lib/* "${PREFIX}/share/star-fusion/lib"
install -m 755 util/* "${PREFIX}/share/star-fusion/util"
install -m 755 FusionFilter/lib/* "${PREFIX}/share/fusion-filter/lib"
install -m 755 FusionFilter/util/* "${PREFIX}/share/fusion-filter/util"

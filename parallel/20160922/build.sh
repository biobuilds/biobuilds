#!/bin/bash

set -o pipefail

./configure --prefix="${PREFIX}"
make
make install

# Make sure the scripts use the conda interpreter when installed
pushd "${PREFIX}/bin"
for fn in niceload parallel parcat sql ; do
    echo "#!${PREFIX}/bin/perl -w" > f
    sed -n '2,$p' "$fn" >> f
    mv -f f "$fn"
    chmod 755 "$fn"
done
popd

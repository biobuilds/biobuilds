#!/bin/bash
set -e -x -o pipefail

# Tell matplotlib to use the "cairo" backend to work around an issue with our
# build containers, wherein matplotlib inexplicably falls back on PyQt4, even
# though PyQt5 (which it was built with) is available in the environment; i.e.,
# "import matplotlib.pyplot" fails with "ImportError: No module named PyQt4".
#
# NOTE: this seems to be a bug that's specific to our build containers; it
# doesn't seem to be happening in a "normal" Linux environment.
if [ `uname -s` == 'Linux' ]; then
    export MPLBACKEND=cairo
fi

python <<EOF
import benchmarks
import skbio
import skbio.alignment
import skbio.alignment._lib
import skbio.alignment.tests
import skbio.diversity
import skbio.diversity.alpha
import skbio.diversity.alpha.tests
import skbio.diversity.beta
import skbio.diversity.beta.tests
import skbio.diversity.tests
import skbio.io
import skbio.io.format
import skbio.io.format.tests
import skbio.io.tests
import skbio.sequence
import skbio.sequence.tests
import skbio.stats
import skbio.stats.distance
import skbio.stats.distance.tests
import skbio.stats.evolve
import skbio.stats.evolve.tests
import skbio.stats.ordination
import skbio.stats.ordination.tests
import skbio.stats.tests
import skbio.tests
import skbio.tree
import skbio.tree.tests
import skbio.util
import skbio.util.tests
EOF

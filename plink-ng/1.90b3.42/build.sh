#!/bin/bash

set -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -Wall"

# Use BioBuilds-provided zlib
CFLAGS="${CFLAGS} -DDYNAMIC_ZLIB"
CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Use BioBuilds-provided OpenBLAS instead of ATLAS
BLASFLAGS="-lopenblas"
if [ `uname -s` == "Darwin" ]; then
    # Libraries containing additional symbols needed on OS X
    BLASFLAGS="${BLASFLAGS} -lgfortran -lgomp"
fi

# Other platform-specific configuration tweaks
if [ `uname -m` == 'ppc64le' ]; then
    CFLAGS="${CFLAGS} -fsigned-char"
    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib"

    # Squash some annoying warnings genearted by veclib headers
    CFLAGS="${CFLAGS} -Wno-deprecated"
    CFLAGS="${CFLAGS} -Wno-narrowing -Wno-sign-compare"
    CFLAGS="${CFLAGS} -Wno-unused-but-set-variable -Wno-unused-variable"
    CFLAGS="${CFLAGS} -Wno-unused-function"

    # Turn "overflow" warnings into errors; this helps us catch problematic
    # static initializations of "__m128"/"__m128i" variables and constants,
    # which can lead to hard-to-track-down bugs. (x86_64 lets us initialize
    # these with arrays of unsigned long longs, but ppc64le requires use of
    # the vec_splat*(..) functions found in veclib headers.)
    CFLAGS="${CFLAGS} -Werror=overflow"
fi


## Build
make -j${BB_MAKE_JOBS} -f Makefile.std \
    CFLAGS="${CFLAGS}" LINKFLAGS_EXTRA="${LDFLAGS}" \
    ZLIB="-lz" BLASFLAGS="${BLASFLAGS}" \
    2>&1 | tee build.log


## Install
mkdir -p "${PREFIX}/bin"
cp -fv plink "${PREFIX}/bin/plink-ng"
chmod 0755 "${PREFIX}/bin/plink-ng"
ln -sf "${PREFIX}/bin/plink-ng" "${PREFIX}/bin/plink19"
#ln -sf "${PREFIX}/bin/plink-ng" "${PREFIX}/bin/plink2"

#!/bin/bash

set -o pipefail
set -e -x

abort() {
    echo "FATAL: ${1:-Unknown error}" >&2
    exit 1
}

## Configure
build_arch=`uname -m`
build_os=`uname -s`

[ "${BB_ARCH_FLAGS}" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "${BB_OPT_FLAGS}" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "${BB_MAKE_JOBS}" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

if [ "$build_arch" == "ppc64le" ]; then
    # Generate a platform-specific Makefile based on the SSE3 one
    VECOPT="VECLIB"
    sed 's/-msse3/-maltivec -mvsx/g; s/SSE3/VECLIB/g' \
        < Makefile.SSE3.PTHREADS.gcc > Makefile.${VECOPT}.PTHREADS.gcc

    CFLAGS="${CFLAGS} -I${PREFIX}/include/veclib -Wno-deprecated"
elif [ "$build_arch" == "x86_64" ]; then
    VECOPT="SSE3"
else
    abort "Unsupported hardware architecture '$build_arch'"
fi


## Build
make -j${BB_MAKE_JOBS} CFLAGS="${CFLAGS}" -f Makefile.${VECOPT}.PTHREADS.gcc


## Install
SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
install -d "${PREFIX}/bin" "${SHARE_DIR}"
install -m 0755 raxmlHPC-PTHREADS-${VECOPT} "${PREFIX}/bin"
install -m 0755 usefulScripts/*.sh "${SHARE_DIR}"
for src in usefulScripts/*.pl; do
    tgt="${SHARE_DIR}/$(basename $src)"
    echo "#!${PREFIX}/bin/perl -w" > "${tgt}"
    sed -n 's/^\$raxmlExecutable.*$/$raxmlExecutable = "raxmlHPC";/; 2,$p' \
        < "$src" >> "$tgt"
    chmod 0755 "$tgt"
done

pushd "${PREFIX}/bin"
ln -s raxmlHPC-PTHREADS-${VECOPT} raxmlHPC
ln -s raxmlHPC-PTHREADS-${VECOPT} raxml

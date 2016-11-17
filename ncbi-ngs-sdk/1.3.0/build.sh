#!/bin/bash
set -o pipefail

# If available, pull in BioBuilds optimization flags
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

cd "${SRC_DIR}/ngs-sdk"

# TODO: figure out how to pass CFLAGS, LDFLAGS to this build system
./configure --prefix="${PREFIX}" \
    --build-prefix="${SRC_DIR}/ngs-sdk/local-build" \
    2>&1 | tee "${SRC_DIR}/configure.log"
make V=1 2>&1 | tee "${SRC_DIR}/build.log"
make test

# "make install" wants to put things in "lib64" which conda doesn't like;
# so we'll symlink "lib64" to "lib" and remove it afterwards.
install -d "${PREFIX}/lib"
(cd "${PREFIX}" && ln -sfn lib lib64)
make install

# OS X: Fix install name of the dynamic library so conda's post-build process
# doesn't get confused (i.e. file not found) when the "lib64" link is removed.
if [ `uname -s` == 'Darwin' ]; then
    pushd "${PREFIX}/lib"
    for fn in libngs-sdk.dylib; do
        libname=$(basename `otool -D "$fn" | tail -n1`)
        install_name_tool -id "$libname" "$fn"
    done
    popd
fi

rm -f "${PREFIX}/lib64"
rm -rf "${PREFIX}/share/examples"

#!/bin/bash
set -o pipefail

build_os="$(uname -s)"
build_arch="$(uname -m)"

# If available, pull in BioBuilds optimization flags
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
export CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
export CXXFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Make sure various libraries are available to "make test"
if [ "$build_os" == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

# "configure" insists on looking for the NGS SDK libraries in "lib64" instead
# of "lib", so create a symlink to trick it.
pushd "${PREFIX}"
[ -e "lib64" ] && \
    { echo "*** ERROR: \$PREFIX/lib64 already exists! ***" >&2; exit 1; }
ln -sfn lib lib64
popd

# Need this environment variable, or the sra-tools build process gets confused
# about how to find/build certain targets (e.g., "kfg/certs.kfg").
export VDB_SRCDIR="${SRC_DIR}/ncbi-vdb-${PKG_VERSION}"

#--------------------------------------------------------------------------
# ncbi-vdb build steps
cd "${VDB_SRCDIR}"

# Clean out previous build, if it exists
rm -rf "local-build"

# Remove pre-generated assembly so everything is built from source
find "libs/search" -name '*.s' | xargs rm -f

# Remove sources for zlib and bzip2; use conda-provided ones instead;
# fixes libxml2 linking issue (see makefiles.patch for details).
rm -rf "libs/ext/zlib" "libs/ext/bzip2"

# Remove sources for libmagic and use conda-provided library instead
rm -rf "libs/ext/magic"

# Remove sources for med TLS and use conda-provied library instead
rm -rf "libs/ext/mbedtls"

# TODO: figure out how to pass CFLAGS, LDFLAGS to this build system
./configure --prefix="${PREFIX}" \
    --build-prefix="${PWD}/local-build" \
    --with-ngs-sdk-prefix="${PREFIX}" \
    --with-xml2-prefix="${PREFIX}" \
    --with-magic-prefix="${PREFIX}" \
    --with-hdf5-prefix="${PREFIX}" \
    LDFLAGS="${LDFLAGS}" \
    2>&1 | tee configure.log

make 2>&1 | tee build.log

# Don't run the built-in tests by default; these take a long time and involve
# moving quite a lot of data (650+ MB) across the Internet.
#env LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" make test 2>&1 | tee test.log

make install

#--------------------------------------------------------------------------
# sra-tools build steps
cd "${SRC_DIR}/sra-tools-${PKG_VERSION}"

# Clean out previous build, if it exists
rm -rf "local-build"

# TODO: figure out how to pass CFLAGS, LDFLAGS to this build system
./configure --prefix="${PREFIX}" \
    --build-prefix="${PWD}/local-build" \
    --with-ngs-sdk-prefix="${PREFIX}" \
    --with-xml2-prefix="${PREFIX}" \
    --with-magic-prefix="${PREFIX}" \
    --with-hdf5-prefix="${PREFIX}" \
    --with-ncbi-vdb-sources="${VDB_SRCDIR}" \
    --with-ncbi-vdb-build="${VDB_SRCDIR}/local-build" \
    LDFLAGS="${LDFLAGS}" \
    2>&1 | tee configure.log

make V=1 2>&1 | tee build.log

#make test 2>&1 | tee test.log

make install


#--------------------------------------------------------------------------
# miscellaneous build steps

# Clean up the install
cd "${PREFIX}"
rm -f lib64                 # don't need lib64 symlink
rm -rf include lib/*.a*     # don't need development headers & libraries
rm -f bin/magic

#!/bin/bash

#set -e -x
set -e
set -o pipefail

## Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

CXXFLAGS="${CXXFLAGS} -fsigned-char"

if [ "$BUILD_OS" == 'darwin' ]; then
    MACOSX_VERSION_MIN=10.8
    CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"

    # Must use the same 'stdlib' option as bamtools, or build will fail with
    # multiple undefined symbols errors.
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
fi

CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/bamtools"

# Additional flags in upstream Makefile that we squash when passing the
# "CXXFLAGS" argument to "make"
CXXFLAGS="${CXXFLAGS} -D_FILE_OFFSET_BITS=64 -fPIC"

# Make sure g++ knows to use a pre-C++11 ABI.
CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0"

BIN_DIR="${PREFIX}/bin"
LIBEXEC_DIR="${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}"

# Removed 3rd-party sources so we don't accidentally use them instead of the
# versions provided by BioBuilds
rm -rf src/utils/BamTools src/utils/sqlite3


# Build
rm -rf bin obj
find . -name '*.o' | xargs rm -f

make -j${MAKE_JOBS} \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    2>&1 | tee build.log


## Install
PREFIX_BIN="${PREFIX}/bin"
PREFIX_ETC="${PREFIX}/etc"
PREFIX_LIBEXEC="${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}"

install -d "${PREFIX_BIN}" "${PREFIX_ETC}" "${PREFIX_LIBEXEC}"

install -m 0755 bin/lumpy "${PREFIX}/bin"
sed "
    s@^CONFIG=.*\$@CONFIG=${PREFIX_ETC}/lumpyexpress.config@;
    s@=.*/bamkit/@${PREFIX_BIN}/@;
    " < bin/lumpyexpress > "${PREFIX_BIN}/lumpyexpress"
chmod 0755 "${PREFIX_BIN}/lumpyexpress"

# Disable the 'errexit' (-e) and 'pipefail' shell options so "grep -qv" in the
# following "for" loop doesn't cause this build script to fail.
set +e +o pipefail

# Install only those support scripts that are either required by the binaries
# or mention in the documentation (README.md)
for path in `find scripts -type f`; do
    fn=`basename "$path"`

    find README.md bin scripts src -type f | \
        xargs egrep -niH "$fn" | \
        grep -qv -- "^${path}"

    if [ $? -eq 0 ]; then
        dest="${PREFIX_LIBEXEC}/${fn}"
        sed -n "
            1s@^#!.*[ /]\(.*\)\$@#!${PREFIX}/bin/\1@p;
            2,\$p;
        " < "$path" > "$dest"
        chmod 0755 "$dest"
    fi
done
set -e -o pipefail

# Config file
cat >"${PREFIX_ETC}/lumpyexpress.config" <<EOF
LUMPY_HOME=${PREFIX_LIBEXEC}

LUMPY=${PREFIX_BIN}/lumpy
SAMBLASTER=${PREFIX_BIN}/samblaster
SAMBAMBA=
SAMTOOLS=${PREFIX_BIN}/samtools
PYTHON=${PREFIX_BIN}/python

PAIREND_DISTRO=${PREFIX_LIBEXEC}/pairend_distro.py
BAMGROUPREADS=${PREFIX_BIN}/bamgroupreads.py
BAMFILTERRG=${PREFIX_BIN}/bamfilterrg.py
BAMLIBS=${PREFIX_BIN}/bamlibs.py
EOF

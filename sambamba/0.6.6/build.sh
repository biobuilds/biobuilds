#!/bin/bash
set -o pipefail

# We haven't been able to successfully build LDC for BioBuilds (at least not on
# POWER), so make sure we have a D compiler accessible through $PATH
set +e
D_COMPILER=`command -v ldmd2`
if [[ "${D_COMPILER}" == "" ]]; then
    echo 'FATAL: Could not find `ldmd2` in $PATH' >&2
    exit 1
fi
LDC_ROOT=$(cd `dirname "$D_COMPILER"`/.. && pwd)
set -e

# Write an LDC config file. Need to do this because we bind mount the LDC
# directory into our (Linux) build containers, and that change of path can
# break the default "ldc2.conf" file. The range of "-I" options comes from the
# fact that we weren't able to get working LDC builds for all the platforms we
# support, so we have to rely on various third-party LDC builds that put the
# standard D include files in various places.
cat >"${SRC_DIR}/ldc.conf" <<EOF
default:
{
    // 'switches' holds array of string that are appends to the command line
    // arguments before they are parsed.
    switches = [
        "-I${LDC_ROOT}/import",
        "-I${LDC_ROOT}/import/ldc",
        "-I${LDC_ROOT}/include/d",
        "-I${LDC_ROOT}/include/d/ldc",
        "-I${LDC_ROOT}/runtime/druntime/src",
        "-I${LDC_ROOT}/runtime/phobos",
        "-L-L${LDC_ROOT}/lib",
        "-defaultlib=phobos2-ldc,druntime-ldc",
        "-debuglib=phobos2-ldc-debug,druntime-ldc-debug"
    ];
};
EOF

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

make clean
LD_LIBRARY_PATH="${PREFIX}/lib" \
    make sambamba-ldmd2-64 \
    LDC_ROOT="${LDC_ROOT}" \
    LDMD_OPTS="-v -conf='${SRC_DIR}/ldc.conf'" \
    CPPFLAGS="-I${PREFIX}/include" \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    2>&1 | tee build.log

mkdir -p "${PREFIX}/bin"
strip build/sambamba
cp -fp build/sambamba "${PREFIX}/bin"
chmod 755 "${PREFIX}/bin/sambamba"

#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Just in case...
CXXFLAGS="${CXXFLAGS} -fsigned-char"

mkdir -p "${PREFIX}/bin"
env CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" PREFIX="${PREFIX}/bin" \
    /bin/bash -e -x install.sh

for fn in `ls *.sh | egrep -v 'script.Summary.ha.sh'`; do
    TGT_PATH="${PREFIX}/bin/CLARK-`basename $fn`"
    cp -p "$fn" "${TGT_PATH}"
    chmod 755 "${TGT_PATH}"
done

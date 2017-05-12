#!/bin/bash
set -o pipefail

## Configure
# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

[ -d "${PREFIX}/include/samtools" ] || \
    { echo "ERROR: could not find samtools headers" >&2; exit 1; }
CPPFLAGS="-I${PREFIX}/include/samtools ${CPPFLAGS}"
CFLAGS="-I${PREFIX}/include/samtools ${CFLAGS}"

# Clean out headers and libraries to prevent conflicts with "system" ones
find . \( -name 'zlib.h' -o -name 'zconf.h' -o -name 'libz*' \) \
    -exec rm -f {} \;
find . \( -name 'bgzf.h' -o -name 'bam.h' -o -name 'sam.h' -o -name 'libbam*' \) \
    -exec rm -f {} \;
find . -type f -name '*curses*' -exec rm -f {} \;
find . \( -name '*.a' -o -name '*.so' -o -name '*.dylib' \) \
    -exec rm -f {} \;

# Force 
CC="${CC} -std=gnu89"
CXX="${CXX} -std=gnu++98"


## Build
make CC="${CC}" CXX="${CXX}" 2>&1 | tee build.log


## Install
[ -d "${PREFIX}/bin" ] || mkdir "${PREFIX}/bin"
cp SOAPdenovo-63mer SOAPdenovo-127mer "${PREFIX}/bin"

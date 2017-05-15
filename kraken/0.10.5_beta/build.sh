#!/bin/bash
set -o pipefail

# Configure

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

CXXFLAGS="${CXXFLAGS} -fsigned-char"

# Restore the flags we squash by passing CXXFLAGS directly to make
CXXFLAGS="${CXXFLAGS} -fopenmp -Wall"

KRAKEN_DIR="${PREFIX}/libexec/kraken-${PKG_VERSION}"
install -d "${KRAKEN_DIR}"
install -d "${PREFIX}/bin"

make -C src -j${MAKE_JOBS} \
    KRAKEN_DIR="${KRAKEN_DIR}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
    LD="${CXX}" LDFLAGS="${LDFLAGS}" \
    install 2>&1 | tee build.log

# Copy the scripts to the destination directory, munging certain variables
# along the way; basically what "install_kranken.sh" does, but we want to make
# sure we don't accidentally re-run the binary build above.
cd scripts
for fn in *; do
    sed "
        s@#####=KRAKEN_DIR=#####@${KRAKEN_DIR}@g;
        s@#####=VERSION=#####@${PKG_VERSION}@g;
    " < "$fn" > "${KRAKEN_DIR}/${fn}"
    chmod 0755 "${KRAKEN_DIR}/${fn}"
done

# Make sure the kraken scripts use BioBuilds, not system, perl
cd "${KRAKEN_DIR}"
for fn in `grep -l '^#!.*perl' *`; do
    sed -n "1s@^.*\$@#!${PREFIX}/bin/perl@p; 2,\$p" "$fn" > "$fn.tmp"
    mv "${fn}.tmp" "$fn"
    chmod 0755 "$fn"
done

# Create symlinks for main scripts
cd "${PREFIX}/bin"
for f in ../libexec/kraken-${PKG_VERSION}/kraken{,-*}; do
    ln -sf "$f" `basename "$f"`
done

#!/bin/bash
set -u

abort() {
    echo "FATAL: ${1:-Unknown error}" >&2
    exit 1
}

: ${PSXE_ROOT:="/opt/intel"}

PKG_MAJOR_VERSION=`cut -d. -f1 <<<"${PKG_VERSION}"`

VERSION_ROOT="${PSXE_ROOT}/compilers_and_libraries_${PKG_VERSION}/linux"
COMPILER_ROOT="${VERSION_ROOT}/compiler"
COMPILER_LIBS="${COMPILER_ROOT}/lib/intel64"

GNU_PREFIX="x86_64-conda_cos6-linux-gnu"

test -d "${VERSION_ROOT}" || \
    abort "Could not find Intel PSXE ${PKG_VERSION} install"

umask 022


# Setup target directories
DEST_LIB="${PREFIX}/lib"
DEST_SHARE="${PREFIX}/share/biobuilds-build"
mkdir -p "${DEST_LIB}" "${DEST_SHARE}"


# Copy shared libraries and other files needed to the "runtime" pacakges
cp -fp "${COMPILER_LIBS}/offload_main" "${DEST_LIB}"
cp -fp "${COMPILER_LIBS}"/*.so* "${DEST_LIB}"


# Write the toolchain environment and configuration files
pushd "${DEST_SHARE}"

ENV_FILE="build-${PKG_NAME/-build/}${PKG_MAJOR_VERSION}.env"
sed -e "s|@@PREFIX@@|${PREFIX}|g;" \
    -e "s|@@PREFIX_LIB@@|${DEST_LIB}|g;" \
    -e "s|@@PREFIX_SHARE@@|${DEST_SHARE}|g;" \
    -e "s|@@COMPILER_VER@@|${PKG_VERSION}|g;" \
    "${RECIPE_DIR}/toolchain.env" > "${ENV_FILE}"
ln -sf "${ENV_FILE}" "${ENV_FILE/${PKG_MAJOR_VERSION}/}"

cat >"icc.cfg" <<EOF
-gnu-prefix=${GNU_PREFIX}-
--sysroot=${PREFIX}/${GNU_PREFIX}/sysroot
EOF

cat >"icpc.cfg" <<EOF
-gnu-prefix=${GNU_PREFIX}-
--sysroot=${PREFIX}/${GNU_PREFIX}/sysroot
EOF

cat >"ifort.cfg" <<EOF
-gnu-prefix=${GNU_PREFIX}-
--sysroot=${PREFIX}/${GNU_PREFIX}/sysroot
EOF

cat >"xild.cfg" <<EOF
-gnu-prefix=${GNU_PREFIX}-
--sysroot=${PREFIX}/${GNU_PREFIX}/sysroot
-shared-intel
-shared-libgcc
EOF

cat >"xiar.cfg" <<EOF
EOF

chmod 664 *.env *.cfg

popd

#!/bin/bash

DEST_DIR="${PREFIX}/share/biobuilds-build"
DEST_FILE="${DEST_DIR}/build-${PKG_NAME/-build/}.env"

mkdir -p "${DEST_DIR}"
sed "s/@@COMPILER_VER@@/${PKG_VERSION}/" \
    < "${RECIPE_DIR}/toolchain.env" > "${DEST_FILE}"
chmod 664 "${DEST_FILE}"

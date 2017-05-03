#!/bin/bash

DEST="${PREFIX}/share/${PKG_NAME}"

mkdir -p "${DEST}"

cp -fv "${RECIPE_DIR}/build.env" "${DEST}"
chmod 644 "${DEST}/build.env"

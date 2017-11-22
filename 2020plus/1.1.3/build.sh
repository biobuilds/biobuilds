#!/bin/bash

BIN_DIR="${PREFIX}/bin"
SHARE_DIR="${PREFIX}/share/${PKG_NAME}"

mkdir -p "${BIN_DIR}" "${SHARE_DIR}"

# Install Python package in $SHARE_DIR instead of `site-packages` because
# various things make assumptions about directory structure that we do not want
# to mess around with.
cp -Rfvp src "${SHARE_DIR}/src"

install -m 644 *.yaml "${SHARE_DIR}"
for d in config data scripts; do
    mkdir -p "${SHARE_DIR}/${d}"
    cp -Rfvp "${d}/." "${SHARE_DIR}/${d}/"
done

sed -i.bak "s|@@BIN_DIR@@|#!${BIN_DIR}|;" 2020plus.py
sed -i.bak "s|@@PY_PKG_DIR@@|${SHARE_DIR}|;" 2020plus.py
install -m 755 ${PKG_NAME}.py "${BIN_DIR}"

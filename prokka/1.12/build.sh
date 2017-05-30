#!/bin/bash

BIN_DIR="${PREFIX}/bin"
SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
DB_DIR="${SHARE_DIR}/db"
DOC_DIR="${SHARE_DIR}/doc"

mkdir -p "${BIN_DIR}" "${SHARE_DIR}" "${DB_DIR}" "${DOC_DIR}"

cp -rfv db/. "${DB_DIR}"

# Missing prokka-manual.txt file?

install -m 755 bin/${PKG_NAME}* "${BIN_DIR}"
pushd "${BIN_DIR}"
rm -f prokka-make_tarball
sed -i.bak "
    s:@@PREFIX_BIN_DIR@@:${BIN_DIR}:g;
    s:@@PREFIX_SHARE_DIR@@:${SHARE_DIR}:g;
    s:@@PREFIX_DB_DIR@@:${DB_DIR}:g;
    s:@@PREFIX_DOC_DIR@@:${DOC_DIR}:g;
" prokka*
rm -f prokka*.bak
popd

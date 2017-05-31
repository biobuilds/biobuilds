#!/bin/bash

BIN_DIR="${PREFIX}/bin"
LIBEXEC_DIR="${PREFIX}/libexec/${PKG_NAME}"
SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${BIN_DIR}" "${LIBEXEC_DIR}" "${SHARE_DIR}"

install -m 644 lib/*.jar "${LIBEXEC_DIR}"
cp -rfv images/. "${SHARE_DIR}/images"
cp -rfv templates/. "${SHARE_DIR}/templates"

pushd "${SRC_DIR}/bin"
for fn in `ls | grep -v '^beast$'`; do
    # Rename the scripts to avoid potential name collisions
    new_fn="beast-${fn}"
    mv "$fn" "${new_fn}"

    # Fix the paths within the scripts
    sed -i.bak "
        s:@@PREFIX_BIN@@:${BIN_DIR}:g;
        s:@@PREFIX_LIBEXEC@@:${LIBEXEC_DIR}:g;
        s:@@PREFIX_SHARE@@:${SHARE_DIR}:g;
        s:@@PREFIX_LIB@@:${PREFIX}/lib:g;
    " "${new_fn}"
done
# Fix paths within the main `beast` script
sed -i.bak "
    s:@@PREFIX_BIN@@:${BIN_DIR}:g;
    s:@@PREFIX_LIBEXEC@@:${LIBEXEC_DIR}:g;
    s:@@PREFIX_SHARE@@:${SHARE_DIR}:g;
    s:@@PREFIX_LIB@@:${PREFIX}/lib:g;
" beast
rm -f *.bak
install -m 755 * "$BIN_DIR"

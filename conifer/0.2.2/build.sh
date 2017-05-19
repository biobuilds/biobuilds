#!/bin/bash
set -o pipefail

mkdir -p "${PREFIX}/bin"
MAIN="${PREFIX}/bin/${PKG_NAME}.py"

echo "#!${PREFIX}/bin/python" > "${MAIN}"
echo "" >> "${MAIN}"
cat "${PKG_NAME}.py" >> "${MAIN}"
chmod 755 "${MAIN}"

cp ${PKG_NAME}_functions.py "${PREFIX}/bin"

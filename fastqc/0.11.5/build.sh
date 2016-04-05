#!/bin/bash

SHARE_DIR="${PREFIX}/share/${PKG_NAME}"

[ -d "$SHARE_DIR" ] || mkdir -p "$SHARE_DIR"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"

sed -i.bak "s:@@prefix@@:${PREFIX}:; s:@@share_dir@@:${SHARE_DIR}:;" fastqc
rm -f fastqc.bak

install -m 0755 fastqc "${PREFIX}/bin"
install -m 0644 *.jar *.txt *.ico "$SHARE_DIR"
for d in Help Configuration Templates net org uk; do
    mkdir -p "${SHARE_DIR}/${d}"
    cp -rvp ${d}/. "${SHARE_DIR}/${d}/"
done
rm -f "${SHARE_DIR}/INSTALL.txt"

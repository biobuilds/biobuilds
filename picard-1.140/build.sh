#!/bin/bash

TGT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
rm -f *.so  # Remove x86-acceleration lib due to portability concerns
cp -rvp . "${TGT}"

cat >"${PREFIX}/bin/picard" <<EOF
#!/bin/bash
command -v java 1>/dev/null 2>/dev/null ||
    { echo "FATAL: Cannot find 'java' executable" >&2; exit 255; }
env CLASSPATH="${TGT}" java -jar "${TGT}/picard.jar" \$@
EOF
chmod 0755 "${PREFIX}/bin/picard"

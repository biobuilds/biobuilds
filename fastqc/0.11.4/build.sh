#!/bin/bash

TGT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp -rvp . "${TGT}"
chmod 0755 "${TGT}/fastqc"

cat >"${PREFIX}/bin/fastqc" <<EOF
#!/bin/bash

# TODO: replace this with conda perl
PERL=\$(command -v perl 2>/dev/null)
[ -x "\$PERL" ] ||
    { echo "FATAL: Cannot find 'perl' executable" >&2; exit 255; }

# TODO: replace this with conda JRE
command -v java 1>/dev/null 2>/dev/null ||
    { echo "FATAL: Cannot find 'java' executable" >&2; exit 255; }

env CLASSPATH="${TGT}" "\$PERL" "${TGT}/fastqc" \$@
EOF
chmod 0755 "${PREFIX}/bin/fastqc"

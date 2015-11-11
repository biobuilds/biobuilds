#!/bin/bash

TGT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
cp -fvp *.jar readme.txt "${TGT}"
cat >"${PREFIX}/bin/igv" <<EOF
#/bin/bash
command -v java 1>/dev/null 2>/dev/null ||
    { echo "FATAL: Cannot find 'java' executable" >&2; exit 255; }

# Platform-specific launch options
if [ `uname -m` == 'Darwin' ]; then
    OTHER_OPTS="-Xdock:name='IGV'"
else
    OTHER_OPTS=""
fi

export CLASSPATH="${TGT}"
exec java -Xmx4000m \\
    \${OTHER_OPTS} \\
    -Dapple.laf.useScreenMenuBar=true \\
    -Djava.net.preferIPv4Stack=true \\
    -jar "${TGT}/igv.jar" "\$@"
EOF
chmod 0755 "${PREFIX}/bin/igv"

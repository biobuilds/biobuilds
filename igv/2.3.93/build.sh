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

JRE_OPTS=
APP_OPTS=
MEM_OPT_SEEN=0

# Platform-specific launch options
if [ `uname -m` == 'Darwin' ]; then
    JRE_OPTS="${JRE_OPTS} -Xdock:name='IGV'"
fi

# Process command line to separate JRE and application arguments; need to do
# this because all JRE options must appear before the "-jar" argument, or they
# will be treated as application arguments, i.e., passed to main().
for arg in \$@; do
    if [[ "\$arg" == "-X"* || "\$arg" == "-D"* ]]; then
        JRE_OPTS="\${JRE_OPTS} \${arg}"
        if [[ "\${arg}" == "-Xmx"* ]]; then
            MEM_OPT_SEEN=1
        fi
    else
        APP_OPTS="\${APP_OPTS} \${arg}"
    fi
done

# Provide a reasonable default for maximum heap size (from upstream script)
if [ \$MEM_OPT_SEEN -eq 0 ]; then
    JRE_OPTS="-Xmx4000m \${JRE_OPTS}"
fi

export CLASSPATH="${TGT}"
exec java \${JRE_OPTS} \\
    -Dapple.laf.useScreenMenuBar=true \\
    -Djava.net.preferIPv4Stack=true \\
    -jar "${TGT}/igv.jar" \${APP_OPTS}
EOF
chmod 0755 "${PREFIX}/bin/igv"

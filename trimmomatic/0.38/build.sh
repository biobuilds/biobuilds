#!/bin/bash

TGT="${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}"

install -m 755 -d "${PREFIX}/bin" "${TGT}" "${TGT}/adapters"
install -m 644 adapters/* "${TGT}/adapters"
install -m 755 "${PKG_NAME}-${PKG_VERSION}.jar" "${TGT}"

cat >"${PREFIX}/bin/${PKG_NAME}" <<EOF
#!/bin/bash
command -v java 1>/dev/null 2>/dev/null ||
    { echo "FATAL: Cannot find 'java' executable" >&2; exit 255; }

#java_ver=\$(java -version 2>&1 | head -n1 | cut -d. -f2)
#[ "\$java_ver" -ge 7 ] 2>/dev/null || \\
#    { echo "FATAL: Java 7 or above required to run ${PKG_NAME}" >&2; exit 1; }

JRE_OPTS=
APP_OPTS=

# Process command line to separate JRE and application arguments; need to do
# this because all JRE options must appear before the "-jar" argument, or they
# will be treated as application arguments, i.e., passed to main().
for arg in \$@; do
    if [[ "\$arg" == "-X"* || "\$arg" == "-D"* ]]; then
        JRE_OPTS="\${JRE_OPTS} \${arg}"
    else
        APP_OPTS="\${APP_OPTS} \${arg}"
    fi
done

export CLASSPATH="${TGT}"
exec java \$JRE_OPTS \\
    -jar "${TGT}/${PKG_NAME}-${PKG_VERSION}.jar" \\
    \$APP_OPTS
EOF
chmod 0755 "${PREFIX}/bin/${PKG_NAME}"

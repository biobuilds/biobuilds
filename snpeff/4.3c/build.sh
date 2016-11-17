#!/bin/bash

JAR_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

sed -i.bak "s:^data.dir =.*$:data.dir = ${JAR_DIR}/data:" snpEff.config

install -m 0755 -d "${PREFIX}/bin" "${JAR_DIR}"
install -m 0644 snpEff.jar snpEff.config "${JAR_DIR}"

# Create launcher script in ${PREFIX}/bin
cat >"${PREFIX}/bin/snpEff" <<EOF
#!/bin/bash

# Make sure 'java' is available through the user's \$PATH
command -v java 1>/dev/null 2>/dev//null || \\
    { echo 'ERROR: Could not find 'java' in your \$PATH.' >&2; exit 1; }

# Assuming "java -version" formats information like the Oracle JRE
java_minor_ver=\$(java -version 2>&1 | head -n1 | cut -d. -f2)
[ "\$java_minor_ver" -ge 7 ] 2>/dev/null || \\
    { echo 'ERROR: Java 7 or later required to run ${PKG_NAME}.'; exit 1; }

# Process command line to separate JRE and application arguments; need to do
# this because all JRE options must appear before the "-jar" argument, or they
# will be treated as application arguments, i.e., passed to main().
JRE_OPTS=
APP_OPTS=
for arg in \$@; do
    if [[ "\$arg" == "-X"* || "\$arg" == "-D"* ]]; then
        JRE_OPTS="\${JRE_OPTS} \${arg}"
    else
        APP_OPTS="\${APP_OPTS} \${arg}"
    fi
done

export CLASSPATH="${JAR_DIR}"
exec java \$JRE_OPTS \\
    -jar "${JAR_DIR}/snpEff.jar" \\
    \$APP_OPTS
EOF
chmod 0755 "${PREFIX}/bin/snpEff"

#!/bin/bash

SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${PREFIX}/bin" "${SHARE_DIR}"

install -m 0644 SnpSift.jar "${SHARE_DIR}"

# Create launcher script in ${PREFIX}/bin
cat >"${PREFIX}/bin/snpSift" <<EOF
#!/bin/bash

# Make sure 'java' is available through the user's \$PATH
command -v java 1>/dev/null 2>/dev//null || \\
    { echo 'ERROR: Could not find 'java' in your \$PATH.' >&2; exit 1; }

# Assuming "java -version" formats information like the Oracle JRE
java_minor_ver=\$(java -version 2>&1 | head -n1 | awk -F. '{print \$2;}')
test \$java_minor_ver -lt 7 2>/dev/null; test_result=\$?
if [ \$test_result -eq 0 ]; then
    echo 'ERROR: Java 1.7 or later must be installed to use snpEff.' >&2;
    exit 1
elif [ \$test_result -ne 1 ]; then
    echo 'ERROR: Could not determine Java version.' >&2
    exit 1
fi

exec java -jar "${SHARE_DIR}/SnpSift.jar" \$@
EOF
chmod 0755 "${PREFIX}/bin/snpSift"

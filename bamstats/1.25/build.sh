#!/bin/bash
set -u

LIBEXEC="${PREFIX}/libexec/${PKG_NAME}"

install -m 0755 -d "${PREFIX}/bin" "${LIBEXEC}"

cp -Rfvp lib/. "${LIBEXEC}/lib/"

for app in BAMStats BAMStats-GUI; do
    cp -fv ${app}-${PKG_VERSION}.jar "${LIBEXEC}"

    cat >"${PREFIX}/bin/${app}" <<EOF
#!/bin/bash

command -v java 1>/dev/null 2>/dev/null ||
    { echo "FATAL: Cannot find 'java' executable" >&2; exit 255; }

java_ver=\$(java -version 2>&1 | head -n1 | cut -d. -f2)
[ "\$java_ver" -ge 6 ] 2>/dev/null || \\
    { echo "FATAL: Java 6 or above required to run ${PKG_NAME}" >&2; exit 1; }

declare -a jre_opts
declare -a app_opts

# Process command line to separate JRE and application arguments; need to do
# this because all JRE options must appear before the "-jar" argument, or they
# will be treated as application arguments, i.e., passed to main().
while [[ "\$1" != "" ]]; do
    case "\$1" in
        -jre-restrict-search | -no-jre-restrict-search | \\
        -agentlib:* | -agentpath:* | -javaagent:* | \\
        -ea | -ea:* | -enableassertions | -enableassertions:* | \\
        -da | -da:* | -disableassertions | -disableassertions:* | \\
        -esa | -enablesystemassertions | -dsa | -disablesystemassertions | \\
        -d32 | -d64 | -X* | -D* \\
        )
            jre_opts+=("\$1")
            ;;
        # TODO: Handle JRE args for alternative VMs
        #-<alternative_vm>) ;;
        -cp | -classpath)
            jre_opts+=("\$1")
            shift
            jre_opts+=("\$1")
            ;;
        *)
            app_opts+=("\$1")
            ;;
    esac
    shift
done

export CLASSPATH="${LIBEXEC}/lib:${LIBEXEC}"
exec java "\${jre_opts[@]}" \\
    -jar "${LIBEXEC}/${app}-${PKG_VERSION}.jar" \\
    "\${app_opts[@]}" \\
EOF

    chmod 755 "${PREFIX}/bin/${app}"
done

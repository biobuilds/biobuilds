#!/bin/bash

JAR_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

install -m 0755 -d "${PREFIX}/bin" "${JAR_DIR}"
install -m 0644 snpEff/SnpSift.jar "${JAR_DIR}"

# Create launcher script in ${PREFIX}/bin
cat >"${PREFIX}/bin/snpSift" <<EOF
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
declare -a jre_opts
declare -a app_opts
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

export CLASSPATH="${JAR_DIR}"
exec java "\${jre_opts[@]}" \\
    -jar "${JAR_DIR}/SnpSift.jar" \\
    "\${app_opts[@]}"
EOF
chmod 0755 "${PREFIX}/bin/snpSift"

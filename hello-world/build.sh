#!/bin/bash

SRC="hello.c"
EXE="hello-world"

mkdir -p "${PREFIX}/bin" "${PREFIX}/share/${PKG_NAME}"

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Record the build environment (for debugging purposes)
env | sort -t= -k1,1 -f | sed "s|${PREFIX}|\$PREFIX|g" \
    > "${PREFIX}/share/${PKG_NAME}/build-env.log"

# Create the source file
cat >"$SRC" <<'EOF'
#include <stdio.h>

int main(int argc, char** argv) {
    printf("hello world!\n");
    return 0;
}
EOF

# Build and install the executable
if [[ "$-" != *x* ]]; then set -x; restore_x_opt=1; fi
"${CC}" ${CFLAGS} ${LDFLAGS} -o "${EXE}" "${SRC}"
install -m 755 "${EXE}" "${PREFIX}/bin"
if [[ ${restore_x_opt:-0} -eq 1 ]]; then set +x; fi

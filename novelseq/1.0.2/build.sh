#!/bin/bash
set -e -x
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

CFLAGS="${CFLAGS} -std=gnu99"
CXXFLAGS="${CXXFLAGS} -std=gnu++98"

case "$BUILD_ARCH" in
    'ppc64le')
        # Just in case, tell the POWER compiler to assume to the same
        # signedness for plain chars as the x86_64 compiler.
        CFLAGS="${CFLAGS} -fsigned-char"
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
esac

# Create directories to put things in as we build them
BIN_DIR="${PREFIX}/bin"
LIBEXEC_DIR="${PREFIX}/libexec/${PKG_NAME}"
SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${BIN_DIR}" "${LIBEXEC_DIR}" "${SHARE_DIR}"

# Wrapper script so the binaries don't clutter up '$PREFIX/bin'
WRAPPER="${BIN_DIR}/novel_cluster"
cat >"${WRAPPER}" <<EOF
#!/bin/bash
set -e
export PATH="${LIBEXEC_DIR}:\${PATH}"
exec "${LIBEXEC_DIR}/novel_cluster" \$@
EOF
chmod 755 "${WRAPPER}"

cp -rvf chros "${SHARE_DIR}/chros"

# If I were less lazy, I'd write a Makefile...
for fn in *.c; do
    "${CC}" ${CFLAGS} ${LDFLAGS} -o "${LIBEXEC_DIR}/${fn/.c/}" "$fn"
done
for fn in *.cpp; do
    "${CXX}" ${CXXFLAGS} ${LDFLAGS} -o "${LIBEXEC_DIR}/${fn/.cpp/}" "$fn"
done

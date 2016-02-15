#!/bin/bash

set -o pipefail

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }
[ -f "${PREFIX}/lib/libhts.a" ] || \
    { echo "Could not find htslib" >&2; exit 1; }

# Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs-only-L zlib)"

if [ "$build_arch" == "ppc64le" ]; then
    # Needed so the ppc64le compiler makes the same assumptions about
    # "unqualified" chars declarations (i.e., those without explicit
    # signedness provided) as the x86_64 compiler.
    CFLAGS="${CFLAGS} -fsigned-char"
fi
if [ "$build_os" == 'Darwin' ]; then
    # Give install_name_tool enough space to work its magic; if not set,
    # tweaking the plugin shared libraries fails.
    LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

# Hard-code plugin path so conda can deal with it on package install
sed -i.bak "s:@@prefix@@:${PREFIX}:g" vcfplugin.c

make -j${BB_MAKE_JOBS} all \
    HTSDIR="${PREFIX}" prefix="${PREFIX}" \
    CFLAGS="${CFLAGS} -Wall" LDFLAGS="${LDFLAGS}"

make HTSDIR="${PREFIX}" test 2>&1 | tee bcftools-tests.log
make HTSDIR="${PREFIX}" prefix="${PREFIX}" install

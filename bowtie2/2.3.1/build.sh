#!/bin/bash
set -o pipefail

# Common build options (should be provided by the "biobuilds-build" package
source "${PREFIX}/share/biobuilds-build/build.env"

case "$BUILD_ARCH" in
    "x86_64")
        POPCNT=1
        ;;
    "ppc64le")
        POPCNT=0

        # Should be provided by the "veclib-headers" package
        [ -d "${PREFIX}/include/veclib" ] || \
            { echo "ERROR: could not find veclib headers" >&2; exit 1; }
        CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include/veclib"

        # Assume the same signedness for plain "char" as the x86_64 compiler
        CXXFLAGS="${CXXFLAGS} -fsigned-char"

        # GCC 6.x switched the default C++ language standard from "gnu++98" to
        # "gnu++14". Explicitly tell g++ to use the older language standard to
        # prevent "looser throw specifier" errors when using AT 10.0 (which is
        # based on gcc 6.3.1) to build the "opt" version of this package.
        CXXFLAGS="-std=gnu++98 ${CXXFLAGS}"

        if [[ "${CXX}" == "/opt/at10.0/bin/g++" ]]; then
            # Disable certain warnings to make debugging this recipe easier
            CXXFLAGS="${CXXFLAGS} -Wno-misleading-indentation"
            CXXFLAGS="${CXXFLAGS} -Wno-return-type"
            CXXFLAGS="${CXXFLAGS} -Wno-unused-but-set-variable"

            # These compiler options are _supposed_ to work around a TBB issue
            # that we suspect is causing the binaries to segfault, but they
            # don't seem to actually work. See "tbb-malloc_proxy.patch" for
            # problem details and how we're actually working around it.
            #CXXFLAGS="${CXXFLAGS} -flifetime-dse=1"
            #CXXFLAGS="${CXXFLAGS} -fno-builtin-memset"
        fi
        ;;
    *)
        echo "ERROR: Unsupported architecture '$build_arch'" >&2
        exit 1
        ;;
esac

# Build
env RELEASE_FLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    CC="${CC}" \
    CXX="${CXX}" \
    make -j${MAKE_JOBS} \
    BITS=64 \
    POPCNT_CAPABILITY=${POPCNT} \
    WITH_TBB=1 \
    2>&1 | tee build.log

# Install
[ -d "${PREFIX}/bin" ] || mkdir "${PREFIX}/bin"
install -m 0755 \
    "${SRC_DIR}/bowtie2" \
    "${SRC_DIR}/bowtie2-align-s" \
    "${SRC_DIR}/bowtie2-align-l" \
    "${SRC_DIR}/bowtie2-build" \
    "${SRC_DIR}/bowtie2-build-s" \
    "${SRC_DIR}/bowtie2-build-l" \
    "${SRC_DIR}/bowtie2-inspect" \
    "${SRC_DIR}/bowtie2-inspect-s" \
    "${SRC_DIR}/bowtie2-inspect-l" \
    "${PREFIX}/bin"

sed -i.bak "1s@^.*\$@#!${PREFIX}/bin/perl -w@" \
    "${PREFIX}/bin/bowtie2"
chmod 0755 "${PREFIX}/bin/bowtie2"
rm -f "${PREFIX}/bin/bowtie2.bak"

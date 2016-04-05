#!/bin/bash

# Configure
build_arch=$(uname -m)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

if [ "$build_arch" == "x86_64" ]; then
    POPCNT=1
elif [ "$build_arch" == "ppc64le" ]; then
    POPCNT=0

    # Should be provided by the "veclib-headers" package
    [ -d "${PREFIX}/include/veclib" ] || \
        { echo "ERROR: could not find veclib headers" >&2; exit 1; }
    CXXFLAGS="-I${PREFIX}/include/veclib ${CXXFLAGS}"

    CXXFLAGS="${CXXFLAGS} -fsigned-char"
else
    echo "ERROR: Unsupported architecture '$build_arch'" >&2
    exit 1
fi

# Build
env RELEASE_FLAGS="${CXXFLAGS}" \
    make -j${BB_MAKE_JOBS} BITS=64 POPCNT_CAPABILITY=${POPCNT}

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

#!/bin/bash

# Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CXXFLAGS="${CXXFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

CPU_ARCH=$(uname -m)
if [ "$CPU_ARCH" == "x86_64" ]; then
    POPCNT=1
elif [ "$CPU_ARCH" == "ppc64le" ]; then
    POPCNT=0
else
    echo "ERROR: Unsupported architecture '$CPU_ARCH'" >&2
    exit 1
fi

# Build
env RELEASE_FLAGS="${CXXFLAGS}" \
    make -j${BB_MAKE_JOBS} BITS=64 POPCNT_CAPABILITY=${POPCNT}

# Install
[ -d "${PREFIX}/bin" ] || mkdir "${PREFIX}/bin"
cp "${SRC_DIR}/bowtie" \
   "${SRC_DIR}/bowtie-align-s" \
   "${SRC_DIR}/bowtie-align-l" \
   "${SRC_DIR}/bowtie-build" \
   "${SRC_DIR}/bowtie-build-s" \
   "${SRC_DIR}/bowtie-build-l" \
   "${SRC_DIR}/bowtie-inspect" \
   "${SRC_DIR}/bowtie-inspect-s" \
   "${SRC_DIR}/bowtie-inspect-l" \
   "${PREFIX}/bin"

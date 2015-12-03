#!/bin/bash

set -o pipefail

# binutils developers recommending building outside source directory
mkdir build
cd build

# Configure options:
# * --disable-nls: don't build natural language support; forces all diagnostic
#   messages to be in English.
# * --enable-ld=no --enable-gold=no: don't build the linkers; we want to be
#   sure that we use the usual linker (ld) provided by the host (build) OS,
#   mostly to avoid potential portability problems with the binaries we
#   generate. (We're building binutils mostly for the updated assembler.)
../configure --prefix="$PREFIX" --disable-nls \
    --enable-ld=no --enable-gold=no \
    2>&1 | tee configure.log

# Since this package isn't really meant for cross-compiling use, provide the
# "tooldir" make argument to skip the target-specific tools installation (i.e.,
# the  programs in "${PREFIX}/<arch>-unknown-linux-gnu/bin"). For more details,
# refer to the "Binutils" section of the "Linux from Scratch" guide at:
# http://www.linuxfromscratch.org/lfs/view/development/chapter06/binutils.html
make -j${CPU_COUNT} tooldir="${PREFIX}"
make check
make install-strip tooldir="${PREFIX}"

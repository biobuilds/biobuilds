#!/bin/bash

mkdir -p "${PREFIX}/lib"
SRC_LIB_DIR="compilers_and_libraries_${PKG_VERSION}/linux/compiler/lib/intel64_lin"

# The "intel-icc-libs" package provides most of the required libraries, so we
# just need to copy over the Fortran-specific ones.
cp -afv "${SRC_LIB_DIR}"/libic* "${PREFIX}/lib"
cp -afv "${SRC_LIB_DIR}"/libif* "${PREFIX}/lib"

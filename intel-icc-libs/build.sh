#!/bin/bash

mkdir -p "${PREFIX}/lib"
cp -afv \
    "compilers_and_libraries_${PKG_VERSION}/linux/compiler/lib/intel64_lin/." \
    "${PREFIX}/lib"

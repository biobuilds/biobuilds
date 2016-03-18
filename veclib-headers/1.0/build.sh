#!/bin/bash

if [ `uname -m` != 'ppc64le' ]; then
    echo "ERROR: veclib headers only available for POWER architectures" >&2
    exit 1
fi
[ -d "$PREFIX/include/veclib" ] || mkdir -p "$PREFIX/include/veclib"
cp -p include/*.h "${PREFIX}/include/veclib"
echo "Version: veclib ${PKG_VERSION}" > "${PREFIX}/include/veclib/VERSION.TXT"

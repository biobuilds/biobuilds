#!/bin/bash

if [ `uname -m` != 'ppc64le' ]; then
    echo "ERROR: veclib headers only available for POWER architectures" >&2
    exit 1
fi
[ -d "$PREFIX/include/veclib" ] || mkdir -p "$PREFIX/include/veclib"
cp -p *.h "${PREFIX}/include/veclib"
cp -p VERSION.TXT "${PREFIX}/include/veclib"

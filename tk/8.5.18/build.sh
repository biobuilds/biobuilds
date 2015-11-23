#!/bin/bash

# Unpack the separate sources
cd "$SRC_DIR"
tar -xf tcl${PKG_VERSION}-src.tar.gz
tar -xf tk${PKG_VERSION}-src.tar.gz

# Build tcl first...
cd "$SRC_DIR/tcl${PKG_VERSION}/unix"
./configure --prefix="$PREFIX" --enable-64bit
make
make install

# ...then build tk
if [ `uname` == Darwin ]; then
    AQUA='--enable-aqua=yes'
fi
cd "$SRC_DIR/tk${PKG_VERSION}/unix"
./configure --prefix="${PREFIX}" \
    --with-tcl="$PREFIX/lib" \
    $AQUA
make
make install

# Clean up the install
cd "$PREFIX"
rm -rf man share

#!/bin/bash

IFS="." read -a VER_ARR <<<"${PKG_VERSION}"

# Build tcl first...
cd "$SRC_DIR/tcl${PKG_VERSION}/unix"
#autoreconf -vfi
./configure --prefix="${PREFIX}"  --enable-64-bit
make -j${CPU_COUNT} ${VERBOSE_AT}
make install

# ...then build tk
if [ `uname` == Darwin ]; then
    AQUA='--enable-aqua=yes'
fi
cd "$SRC_DIR/tk${PKG_VERSION}/unix"
#autoreconf -vfi
./configure --prefix="${PREFIX}" \
    --with-tcl="${PREFIX}/lib" \
    $AQUA
make -j${CPU_COUNT} ${VERBOSE_AT}
make install

# Clean up the install
rm -rf "${PREFIX}"/{man,share}

# Link binaries to non-versioned names to make them easier to find and use.
ln -s "${PREFIX}/bin/tclsh${VER_ARR[0]}.${VER_ARR[1]}" "${PREFIX}/bin/tclsh"
ln -s "${PREFIX}/bin/wish${VER_ARR[0]}.${VER_ARR[1]}" "${PREFIX}/bin/wish"

# copy headers
cp -p "${SRC_DIR}"/tk${PKG_VERSION}/{unix,generic}/*.h "${PREFIX}/include/"

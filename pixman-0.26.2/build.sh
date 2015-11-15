#!/bin/bash

cp -fv "${PREFIX}/share/autoconf/config.guess" config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" config.sub

# NOTE: disabling use of Altivec/VMX intrinisics due to the POWER8 big- to
# little-endian changes that we haven't had time to verify/debug yet.
env PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
    CPPFLAGS="-I${PREFIX}/include" \
    LDFLAGS="-L${PREFIX}/lib" \
    ./configure --prefix="$PREFIX" --disable-gtk --enable-libpng \
        --disable-vmx

make V=1 -j${CPU_COUNT}
make check
make install

#!/bin/sh

cp -fv "${PREFIX}/share/autoconf/config.guess" build-aux/config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" build-aux/config.sub

export M4="${PREFIX}/bin/m4"

./configure --prefix="${PREFIX}" \
            PERL='/usr/bin/env perl'
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
rm -rf "${PREFIX}/share/info"

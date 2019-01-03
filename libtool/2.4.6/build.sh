#!/bin/sh

export HELP2MAN=$(which true)
export M4="${PREFIX}/bin/m4"

cp -fv "${PREFIX}/share/autoconf/config.guess" build-aux/config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" build-aux/config.sub

./configure --prefix="${PREFIX}" \
            --enable-ltdl-install \
            --with-pic
make -j${MAKE_JOBS} ${VERBOSE_AT}
make install

rm -rf "${PREFIX}/share/info"

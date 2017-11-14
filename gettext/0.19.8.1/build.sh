#!/usr/bin/bash

./configure --prefix="${PREFIX}" \
    --with-pic \
    --enable-shared \
    --enable-static \
    --enable-threads=posix \
    --without-libpth-prefix \
    --enable-relocatable \
    --disable-c++ \
    --disable-java \
    --disable-native-java \
    --disable-libasprintf \
    --disable-acl \
    --disable-openmp \
    --disable-curses \
    --without-libncurses-prefix \
    --without-libtermcap-prefix \
    --without-libxcurses-prefix \
    --without-libcurses-prefix \
    --without-libiconv-prefix \
    --without-libintl-prefix \
    --without-libglib-2.0-prefix \
    --without-libcroco-0.6-prefix \
    --without-libunistring-prefix \
    --without-libxml2-prefix \
    --without-emacs \
    --without-lispdir \
    --without-git \
    --without-cvs \
    --with-bzip2 \
    --without-xz \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT}
make install

rm -rf ${PREFIX}/share/{doc,info,man}

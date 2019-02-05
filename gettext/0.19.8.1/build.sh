#!/usr/bin/env bash

./configure --prefix="${PREFIX}" \
    --with-pic \
    --enable-shared \
    --enable-static \
    --enable-threads=posix \
    --without-libpth-prefix \
    --enable-rpath \
    --enable-relocatable \
    --enable-nls \
    --enable-largefile \
    --disable-c++ \
    --disable-java \
    --disable-native-java \
    --disable-csharp \
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
    --with-included-libunistring \
    --without-libxml2-prefix \
    --without-emacs \
    --without-lispdir \
    --without-git \
    --without-cvs \
    --with-bzip2 \
    --without-xz \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT} \
    2>&1 | tee build.log

make install
rm -rf ${PREFIX}/share/doc
rm -rf ${PREFIX}/share/info

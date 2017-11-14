#!/bin/bash

set -x

# Use the C++11 standard, rather than C++98/GNU++98 (default for g++ 4.8.x
# that's our default compiler for POWER8 packages). Otherwise, C++ compilation
# may fail with errors arising from the THROWS and THROW2 macros.
export CXXFLAGS="-std=c++11 ${CXXFLAGS}"

./configure \
  --prefix="${PREFIX}" \
  --without-debug \
  --without-ada \
  --without-manpages \
  --with-shared \
  --disable-overwrite \
  --enable-symlinks \
  --enable-termcap \
  --with-pkg-config-libdir="${PREFIX}/lib/pkgconfig" \
  --enable-pc-files \
  --with-termlib \
  --enable-widec
make -j${CPU_COUNT} ${VERBOSE_AT}
make install

if [[ $(uname -s) == Linux ]]; then
  _SOEXT=.so
else
  _SOEXT=.dylib
fi

# Make symlinks from the wide to the non-wide libraries.
pushd ${PREFIX}/lib
  for _LIB in ncurses ncurses++ form panel menu tinfo; do
    if [[ -f lib${_LIB}w${_SOEXT} ]]; then
      ln -s lib${_LIB}w${_SOEXT} lib${_LIB}${_SOEXT}
    fi
    if [[ -f lib${_LIB}w.a ]]; then
      ln -s lib${_LIB}w.a lib${_LIB}.a
    fi
    pushd pkgconfig
      if [[ -f ${_LIB}w.pc ]]; then
        ln -s ${_LIB}w.pc ${_LIB}.pc
      fi
    popd
  done
  pushd pkgconfig
    for _PC in form formw menu menuw panel panelw ncurses ncursesw ncurses++ ncurses++w tinfo tinfow; do
      sed -i.bak 's:include/ncursesw$:include/ncurses:g' ${_PC}.pc
      [[ -f ${_PC}.pc.bak ]] && rm ${_PC}.pc.bak
    done
  popd
popd

# Provide headers in `$PREFIX/include` and
# symlink them in `$PREFIX/include/ncurses`
# and in `$PREFIX/include/ncursesw`.
HEADERS_DIR_W="${PREFIX}/include/ncursesw"
HEADERS_DIR="${PREFIX}/include/ncurses"
mkdir -p "${HEADERS_DIR}"
for HEADER in $(ls $HEADERS_DIR_W); do
  mv "${HEADERS_DIR_W}/${HEADER}" "${PREFIX}/include/${HEADER}"
  ln -s "${PREFIX}/include/${HEADER}" "${HEADERS_DIR_W}/${HEADER}"
  ln -s "${PREFIX}/include/${HEADER}" "${HEADERS_DIR}/${HEADER}"
done

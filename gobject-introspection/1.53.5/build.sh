#!/bin/bash

set -e -o pipefail

declare -a configure_args

configure_args+=(--prefix=${PREFIX})
#configure_args+=(--host=${HOST})
configure_args+=(--disable-dependency-tracking)
configure_args+=(--enable-shared)
configure_args+=(--disable-static)
configure_args+=(--disable-gtk-doc)
configure_args+=(--disable-gtk-doc-html)
configure_args+=(--disable-gtk-doc-pdf)
configure_args+=(--with-cairo)

[[ ${PY3K:-0} -eq 1 ]] \
    && configure_args+=(--with-python=${PYTHON}3) \
    || configure_args+=(--with-python=${PYTHON})

./configure "${configure_args[@]}" 2>&1 | tee configure.log
make -j${CPU_COUNT} ${VERBOSE_AT}
make install

if [ `uname -s` == 'Linux' ]; then
    #echo "Skipping make check on linux due to libtool cross bug"
    make check
else
    # Test suite does not fully work on OSX, but not because anything is broken.
    make check-local check-TESTS
    (cd tests && make check-TESTS) || exit 1
    (cd tests/offsets && make check) || exit 1
    (cd tests/warn && make check) || exit 1
fi

rm -f "${PREFIX}/lib/libgirepository-*.a" "${PREFIX}/lib/libgirepository-*.la"
rm -rf "${PREFIX}/share/man"

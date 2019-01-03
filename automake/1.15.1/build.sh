#!/bin/sh

# Fix shebangs
for f in bin/aclocal.in bin/automake.in t/wrap/aclocal.in t/wrap/automake.in; do
    sed -i.bak -e '1s|^#!.*$|#!/usr/bin/env perl|' "$f"
    rm -f "$f.bak"
done

cp -fv "${PREFIX}/share/autoconf/config.guess" lib/config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" lib/config.sub

./configure --prefix="$PREFIX"
make ${VERBOSE_AT}
#make check
make install

rm -rfv "${PREFIX}"/share/doc/automake* "${PREFIX}"/share/info/automake*

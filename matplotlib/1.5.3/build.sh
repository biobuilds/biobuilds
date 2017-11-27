#!/bin/bash

if [ `uname` == 'Linux' ]; then
    pushd $PREFIX/lib
    [ -f libtcl${tk}.so ] && ln -s libtcl${tk}.so libtcl.so
    [ -f libtk${tk}.so ]  && ln -s libtk${tk}.so libtk.so
    popd
fi

if [ `uname -m` == 'ppc64le' ]; then
    rm -rf "${PREFIX}/lib/python2.7/lib-tk"
fi

cp -f setup.cfg.template setup.cfg
sed -i.orig "s:/usr/local:$PREFIX:g" setupext.py
$PYTHON setup.py install

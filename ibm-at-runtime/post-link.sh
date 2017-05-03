#!/bin/bash

abort() {
    echo "*** FATAL: ${1:-Unknown error}" > "${PREFIX}/.messages.txt"
    exit 1
}

ARCH=`uname -m`
[ "$ARCH" == 'ppc64le' ] || \
    abort "AT runtime is not supported on $ARCH systems."
[ -f "/opt/at${PKG_VERSION}/lib64/ld64.so.2" ] || \
    abort "Could not find the AT ${PKG_VERSION} runtime."

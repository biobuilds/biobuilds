#!/bin/bash

# Just in case these didn't get carried over...
: ${HOST_ARCH:=`uname -m | tr A-Z a-z`}
: ${HOST_OS:=`uname -s | tr A-Z a-z`}

make install

# Change paths in the installed package for the compiler, includes, libraries,
# etc.  from `${BUILD_PREFIX}` to `${PREFIX}`, or users may have difficulty
# building and installing extension (XS) modules using, e.g., `cpan install`.
pushd "${PREFIX}/lib/perl5/${PKG_VERSION}"
sed -i.bak "s,${BUILD_PREFIX},${PREFIX},g" \
    "${HOST_ARCH}-${HOST_OS}-threaded/Config.pm" \
    "${HOST_ARCH}-${HOST_OS}-threaded/Config_heavy.pl"
rm -f ${HOST_ARCH}-${HOST_OS}-threaded/*.pm.bak

#!/bin/bash

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1

# NOTE: "-Duserelocatableinc" option builds a "relocatable perl tree", which is
# the magic needed to install Perl inside conda environments. This option is
# incompatible with building a shared Perl library (i.e., the "-Duseshrplib"
# and "-Dlibperl="libperl.so.<ver>" options); see the INSTALL file for details.
./Configure -de -Dprefix="${PREFIX}" \
    -Accflags="${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}" \
    -UDEBUGGING -Doptimize="-O3" \
    -Duse64bitall -Duselargefiles \
    -Dusethreads \
    -Duserelocatableinc \
    2>&1 | tee configure.log

make -j$BB_MAKE_JOBS
make -j$BB_MAKE_JOBS test
make install
rm -rf "${PREFIX}/man"

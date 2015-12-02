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
    -Dman1dir="${PREFIX}/share/man/man1" \
    -Dman3dir="${PREFIX}/share/man/man3" \
    -Dsiteman1dir="${PREFIX}/share/man/man1" \
    -Dsiteman3dir="${PREFIX}/share/man/man3" \
    -Dman1ext="1" -Dman3ext="3perl" \
    2>&1 | tee configure.log

make -j$BB_MAKE_JOBS
make -j$BB_MAKE_JOBS test
make install

#!/bin/bash
set -o pipefail

## Configure
build_arch=$(uname -m)
build_os=$(uname -s)

[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -fsigned-char"
CXXFLAGS="${CFLAGS}"

# Squash annoying boost-related warnings
CXXFLAGS="${CXXFLAGS} -Wno-unused-local-typedefs"

if [ "$build_os" == 'Darwin' ]; then
    # Need GCC to compile C++11 while using libstdc++, which is what
    # the BioBuilds Boost OS X libraries (dylibs) link to
    export CC="${PREFIX}/bin/gcc"
    export CXX="${PREFIX}/bin/g++"
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    export MACOSX_DEPLOYMENT_TARGET=10.8

    # Needed only with Apple's clang
    #CXXFLAGS="${CXXFLAGS} -DGTEST_USE_OWN_TR1_TUPLE=1"
fi

mkdir -p "${SRC_DIR}/build"
cd "${SRC_DIR}/build"

rm -rf *
cmake -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    .. 2>&1 | tee configure.log


## Build
make -j${BB_MAKE_JOBS} 2>&1 | tee build.log
#make test ARGS="-V" 2>&1 | tee test.log


## Install
make install

# Move the Perl scripts and modules to better locations
SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
PERL_LIB=$(find "${PREFIX}/lib" -maxdepth 1 -name "${PKG_NAME}-*" -type d)
mkdir -p "${SHARE_DIR}"
mv "${PERL_LIB}"/*.pm "${SHARE_DIR}"
mv "${PERL_LIB}"/*.pl "${PREFIX}/bin"
rmdir "${PERL_LIB}"

chmod u+w "${SHARE_DIR}"/*.pm "${PREFIX}/bin"/*.pl
cd "${PREFIX}"
patch -p0 <<PATCH
--- bin/bam2cfg.pl
+++ bin/bam2cfg.pl
@@ -1,4 +1,4 @@
-#!/usr/bin/env perl
+#!${PREFIX}/bin/perl
 #Create a BreakDancer configuration file from a set of bam files
 
 use strict;
@@ -6,8 +6,7 @@
 use Getopt::Std;
 use Statistics::Descriptive;
 use GD::Graph::histogram;
-use FindBin qw(\$Bin);
-use lib "\$FindBin::Bin";
+use lib "${PREFIX}/share/${PKG_NAME}";
 #use lib '/gscuser/kchen/1000genomes/analysis/scripts/';
 use AlnParser;
 
--- share/${PKG_NAME}/AlnParser.pm
+++ share/${PKG_NAME}/AlnParser.pm
@@ -1,4 +1,4 @@
-#!/gsc/bin/perl
+#!${PREFIX}/bin/perl
 #Parse different alignment format and convert it to MAQ format
 
 use strict;
--- share/${PKG_NAME}/Poisson.pm
+++ share/${PKG_NAME}/Poisson.pm
@@ -1,4 +1,4 @@
-#!/gsc/bin/perl
+#!${PREFIX}/bin/perl
 
 use strict;
 use warnings;
PATCH

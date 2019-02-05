#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

declare -a config_opts

config_opts+=(--disable-debug)          # turn off debugging features
config_opts+=(--enable-shared)          # build shared libraries
config_opts+=(--enable-static)          # build static libraries
config_opts+=(--with-pic)               # generate position-independent code
config_opts+=(--enable-dynamic)         # link binaries to shared libraries

config_opts+=(--enable-ipv6)            # IPv6 support
config_opts+=(--enable-local)           # AF_UNIX socket support

config_opts+=(--disable-syslog)         # syslog support
config_opts+=(--enable-proctitle)       # proctitle support

config_opts+=(--disable-slapd)          # do NOT build standalone server

config_opts+=(--without-cyrus-sasl)     # Cyrus SASL support
#config_opts+=(--with-fetch)             # fetch(3) URL support
config_opts+=(--with-threads)           # multi-threaded support
config_opts+=(--with-tls=openssl)       # TLS/SSL support
#config_opts+=(--with-mp=gmp)            # Multiple precision stats
#config_opts+=(--with-odbc=unixodbc)     # ODBC support

# Update so `./configure` knows how to deal with newer systems
cp -fv "${BUILD_PREFIX}/share/autoconf/config.guess" "build/config.guess"
cp -fv "${BUILD_PREFIX}/share/autoconf/config.sub" "build/config.sub"

./configure --prefix="${PREFIX}" \
    "${config_opts[@]}" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} \
    2>&1 | tee build.log

make install

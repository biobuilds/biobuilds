#!/bin/bash
set -o pipefail

case `uname -s` in
    Darwin)
        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
        export CC=clang
        export CXX=clang++
        ;;
esac

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -m64 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Left to defaults:
#   --enable-libcurl-option
#   --enable-versioned-symbols
#   --ensable-verbose
#   --with-default-ssl-backend=NAME
./configure --prefix="${PREFIX}" \
    --enable-pthreads \
    --enable-optimize \
    --disable-debug \
    --disable-curldebug \
    --enable-shared \
    --disable-static \
    --enable-largefile \
    --disable-manual \
    --enable-unix-sockets \
    --enable-ipv6 \
    --enable-proxy \
    --without-libmetalink \
    --enable-http \
    --enable-cookies \
    --without-libpsl \
    --enable-ftp \
    --enable-tftp \
    --enable-file \
    --enable-smb \
    --disable-ntlm-wb \
    --disable-sspi \
    --enable-smtp \
    --enable-pop3 \
    --enable-imap \
    --disable-ldap \
    --disable-ldaps \
    --disable-rtsp \
    --without-librtmp \
    --disable-gopher \
    --disable-dict \
    --with-libssh2="${PREFIX}" \
    --enable-telnet \
    --with-ssl="${PREFIX}" \
    --with-ca-bundle="${PREFIX}/ssl/cacert.pem" \
    --with-ca-path="${PREFIX}/etc/certs" \
    --with-ca-fallback \
    --without-winssl \
    --without-darwinssl \
    --without-gnutls \
    --without-polarssl \
    --without-mbedtls \
    --without-cyassl \
    --without-axtls \
    --enable-crypto-auth \
    --enable-tls-srp \
    --without-gssapi \
    --disable-ares \
    --without-nss \
    --enable-threaded-resolver \
    --without-winidn \
    --with-libidn2="${PREFIX}" \
    --without-nghttp2 \
    --without-zsh-functions-dir \
    --with-zlib="${PREFIX}" \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT}

# TODO :: test 1119... exit FAILED
# make test

make install

# Clean up the install a little
rm -rf "${PREFIX}/share"

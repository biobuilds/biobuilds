#!/bin/bash
set -o pipefail

# Need so ./configure knows where to find OpenSSL libs
if [ $(uname -s) == 'Darwin' ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

CFLAGS="${CFLAGS} -m64 -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

## Configure
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
    --with-zlib="${PREFIX}" \
    --with-ssl="${PREFIX}" \
    --with-ca-bundle="${PREFIX}/etc/certs/ca-bundle.pem" \
    --with-ca-path="${PREFIX}/etc/certs" \
    --with-ca-fallback \
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
    --enable-file \
    --enable-smb \
    --disable-ntlm-wb \
    --disable-sspi \
    --enable-smtp \
    --enable-imap \
    --enable-pop3 \
    --disable-ldap \
    --disable-ldaps \
    --disable-rtsp \
    --without-librtmp \
    --enable-tftp \
    --disable-gopher \
    --disable-dict \
    --with-libssh2 \
    --enable-telnet \
    --without-winssl \
    --without-darwinssl \
    --without-gnutls \
    --without-cyassl \
    --without-polarssl \
    --without-mbedtls \
    --without-axtls \
    --enable-crypto-auth \
    --enable-tls-srp \
    --without-nss \
    --enable-threaded-resolver \
    --without-winidn \
    --with-libidn="${PREFIX}" \
    --without-nghttp2 \
    --without-zsh-functions-dir \
    2>&1 | tee configure.log

make
make install-strip

# Clean up the install a little
rm -rf "${PREFIX}/share/man" "${PREFIX}/share/aclocal"

# Install the Firefox CA certificate bundle
[ -d "${PREFIX}/etc/certs/ca" ] || mkdir -p "${PREFIX}/etc/certs/ca"
cp -pvf "${RECIPE_DIR}/ca-bundle.pem" "${PREFIX}/etc/certs/ca-bundle.pem"

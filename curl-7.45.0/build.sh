#!/bin/bash
set -o pipefail

# Need so ./configure knows where to find OpenSSL libs
if [ $(uname -s) == 'Darwin' ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
fi

## Configure
./configure --prefix="${PREFIX}" \
    --with-zlib="${PREFIX}" --with-ssl="${PREFIX}" \
    --enable-optimize --disable-debug --disable-curldebug \
    --enable-shared --disable-static \
    --enable-largefile \
    --disable-manual \
    --with-ca-bundle="${PREFIX}/etc/certs/ca-bundle.crt" \
    --without-ca-path \
    --disable-unix-sockets --enable-ipv6 --enable-proxy \
    --enable-http --enable-cookies --enable-ftp --enable-file \
    --disable-smb --disable-ntlm-wb --disable-sspi \
    --disable-smtp --disable-imap --disable-pop3 \
    --disable-ldap --disable-ldaps \
    --disable-rtsp --without-librtmp \
    --disable-tftp --disable-gopher --disable-dict \
    --without-libssh2 --disable-telnet \
    --without-winssl --without-darwinssl \
    --without-gnutls --without-cyassl --without-polarssl \
    --enable-crypto-auth --enable-tls-srp \
    --without-winidn --with-libidn="${PREFIX}" \
    --without-nghttp2 \
    2>&1 | tee configure.log
make
make install-strip

# Clean up the install a little
rm -rf "${PREFIX}/share/man" "${PREFIX}/share/aclocal"

# Install the Firefox CA certificate bundle (pre Sept. 2014); these include
# weak/outdated 1024-bit RSA keys, but are being included due to some possible
# issues OpenSSL may have with RFC 4158 "patch discovery". For details, refer
# to the CURL "CA Extract" page (http://curl.haxx.se/docs/caextract.html).
[ -d "${PREFIX}/etc/certs/ca" ] || mkdir -p "${PREFIX}/etc/certs/ca"
cp -pvf "${RECIPE_DIR}/ca-bundle.crt" "${PREFIX}/etc/certs/ca-bundle.crt"

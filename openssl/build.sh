#!/bin/bash

if [ `uname -m` == 'ppc64le' ]; then
    TARGET="linux-ppc64le"
else
    # Refer to meta.yaml for an explanation
    echo "Cowardly refusing to rebuild OpenSSL on non-ppc64le platforms." >&2
    exit 1
fi

./Configure $TARGET \
    --prefix="${PREFIX}" \
    -I"${PREFIX}/include" -L"${PREFIX}/lib" \
    shared zlib-dynamic \
    2>&1 | tee configure.log
make
make test
make install

rm -rf "${PREFIX}/ssl/man"

# Install the Firefox CA certificate bundle (pre-Sept. 2014); these include
# weak/outdated 1024-bit RSA keys, but are being included due to some possible
# issues OpenSSL may have with RFC 4158 "patch discovery". For details, refer
# to the CURL "CA Extract" page (http://curl.haxx.se/docs/caextract.html).
cp -f "${RECIPE_DIR}/cacert.pem" "${PREFIX}/ssl/cacert.pem"

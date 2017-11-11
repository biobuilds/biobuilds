#!/bin/bash
set -o pipefail

case `uname -s` in
    'Darwin')
        export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
        ;;
    'Linux')
        export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
        ;;
    *)
        echo "FATAL: Unsupport operating system" >&2
        exit 1
        ;;
esac

# Update autoconf files to recognize little-endian POWER
cp -fv "${PREFIX}/share/autoconf/config.guess" config/config.guess
cp -fv "${PREFIX}/share/autoconf/config.sub" config/config.sub

# Pass explicit paths to the prefix for each dependency.
./configure --prefix="${PREFIX}" \
            --with-zlib-include-dir="${PREFIX}/include" \
            --with-zlib-lib-dir="${PREFIX}/lib" \
            --with-jpeg-include-dir="${PREFIX}/include" \
            --with-jpeg-lib-dir="${PREFIX}/lib" \
            --with-lzma-include-dir="${PREFIX}/include" \
            --with-lzma-lib-dir="${PREFIX}/lib" \
            --without-x \
            2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT}
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install

rm -rf "${TIFF_BIN}" "${TIFF_SHARE}" "${TIFF_DOC}"

# For some reason --docdir is not respected above.
rm -rf "${PREFIX}/share"

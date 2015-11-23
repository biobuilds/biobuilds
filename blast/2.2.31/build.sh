#!/bin/bash

command -v pkg-config >/dev/null || \
    { echo "Could not find 'pkg-config' command" >&2; exit 1; }

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} $(pkg-config --cflags zlib)"
LDFLAGS="${LDFLAGS} $(pkg-config --libs zlib)"

cd "${SRC_DIR}/c++"

# Update autoconf files for ppc64le detection
cp -f "${RECIPE_DIR}/config.guess" "src/build-system/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "src/build-system/config.sub"

# Set (DY)LD_LIBRARY_PATH so ./configure works properly
# NOTE: don't use "--with-bin-release" (causes static linking to libstdc++)
env LD_LIBRARY_PATH="${PREFIX}/lib" DYLD_LIBRARY_PATH="${PREFIX}/lib" \
    CFLAGS="${CFLAGS}" CXXFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" --with-build-root=BUILD \
    --with-projects="${RECIPE_DIR}/ncbi-blast.lst" --without-caution \
    --without-autodep --without-makefile-auto-update --with-flat-makefile \
    --without-debug --without-symbols --without-profiling \
    --with-optimization --with-openmp --with-mt \
    --with-64 --with-lfs --with-dll \
    --without-bundles --without-universal \
    --with-z --with-bz2 --without-lzo \
    --with-openssl --without-gnutls --without-gcrypt --without-ncbi-crypt \
    --without-pcre --without-boost \
    --without-gui --without-gbench \
    --without-opengl --without-mesa \
    --without-glut --without-glew --without-ftgl \
    --without-wxwidgets --without-freetype --without-xpm \
    --without-gif --without-jpeg --without-png --without-tiff \
    --without-expat --without-libxml --without-libxslt --without-libexslt \
    --without-sablot --without-xerces --without-xalan --without-zorba \
    --without-python --without-perl --without-jni \
    --without-dbapi --without-bdb --without-sqlite3 --without-mysql \
    --without-sybase --without-ftds --without-mongodb \
    --without-hdf5 --without-avro \
    --without-krb5 --without-curl --without-fastcgi \
    --without-gsoap --without-orbacus \
    --without-icu --without-magic --without-mimetic --without-muparser \
    --without-oechem --without-sge \
    --without-internal --without-connext


## Build
cd "${SRC_DIR}/c++/BUILD/build"
make -f Makefile.flat -j${BB_MAKE_JOBS}


## Install
cd "${SRC_DIR}/c++/BUILD"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"
[ -d "${PREFIX}/lib" ] || mkdir -p "${PREFIX}/lib"
rm -f bin/project_tree_builder bin/test_pcre lib/*.a \
    bin/legacy_blast.pl bin/windowmasker_2.2.22_adapter.py
cp -R bin/. "${PREFIX}/bin"
cp -R lib/. "${PREFIX}/lib"

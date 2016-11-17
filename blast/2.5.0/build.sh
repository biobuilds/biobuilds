#!/bin/bash
set -o pipefail

## Configure
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"

CFLAGS="${CFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cd "${SRC_DIR}/c++"

# Update autoconf files for ppc64le detection
cp -f "${PREFIX}/share/autoconf/config.guess" "src/build-system/config.guess"
cp -f "${PREFIX}/share/autoconf/config.sub" "src/build-system/config.sub"

# Set (DY)LD_LIBRARY_PATH so ./configure works properly
# NOTE: don't use "--with-bin-release" (causes static linking to libstdc++)
env LD_LIBRARY_PATH="${PREFIX}/lib" DYLD_LIBRARY_PATH="${PREFIX}/lib" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ./configure --prefix="${PREFIX}" \
        --with-build-root=BUILD \
        --with-projects="${RECIPE_DIR}/ncbi-blast.lst" \
        --without-caution \
        --without-autodep \
        --without-makefile-auto-update \
        --with-flat-makefile \
        --without-debug \
        --without-profiling \
        --without-symbols \
        --with-strip \
        --without-hostspec \
        --with-check \
        --with-optimization \
        --with-openmp \
        --with-mt \
        --with-64 \
        --with-lfs \
        --with-dll \
        --without-bundles \
        --with-z \
        --with-bz2 \
        --without-lzo \
        --with-openssl \
        --without-gnutls \
        --without-gcrypt \
        --without-ncbi-crypt \
        --without-sasl2 \
        --without-pcre \
        --without-boost \
        --without-gmp \
        --without-lapack \
        --without-gmock \
        --without-gui \
        --without-gbench \
        --without-vdb \
        --without-opengl \
        --without-mesa \
        --without-glut \
        --without-glew \
        --without-ftgl \
        --without-wxwidgets \
        --without-freetype \
        --without-xpm \
        --without-gif \
        --without-jpeg \
        --without-png \
        --without-tiff \
        --without-expat \
        --without-libxml \
        --without-libxslt \
        --without-libexslt \
        --without-sablot \
        --without-xerces \
        --without-xalan \
        --without-zorba \
        --without-python \
        --without-perl \
        --without-jni \
        --without-dbapi  \
        --without-bdb \
        --without-sqlite3 \
        --without-mysql \
        --without-sybase \
        --without-ftds \
        --without-mongodb \
        --without-lmdb \
        --without-hdf5 \
        --without-cereal \
        --without-avro \
        --without-krb5 \
        --without-curl \
        --without-local-lbsm \
        --without-fastcgi \
        --without-gsoap \
        --without-orbacus \
        --without-icu \
        --without-magic \
        --without-mimetic \
        --without-muparser \
        --without-oechem \
        --without-sge \
        --without-internal \
        --without-connext \
        2>&1 | tee configure.log


## Build
cd "${SRC_DIR}/c++/BUILD/build"
make -f Makefile.flat -j${BB_MAKE_JOBS} 2>&1 | tee build.log


## Install
cd "${SRC_DIR}/c++/BUILD"
install -d "${PREFIX}/bin" "${PREFIX}/lib"
rm -f bin/project_tree_builder bin/test_pcre lib/*.a
install -m 0755 bin/* "${PREFIX}/bin"
install -m 0755 lib/* "${PREFIX}/lib"

cd "${PREFIX}/bin"
for fn in update_blastdb.pl legacy_blast.pl windowmasker_2.2.22_adapter.py; do
    sed -i.bak "s:@@PREFIX@@:${PREFIX}:" "$fn"
    rm -f "${fn}.bak"
done

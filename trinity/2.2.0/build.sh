#!/bin/bash -e
set -o pipefail

## Modify these to fit current trinity distribution
JELLYFISH_VERSION="2.1.4"
FASTOOL_VERSION="fstrozzi-Fastool-7c3e034f05"
TRIMMOMATIC_VERSION="0.32"
COLLECTL_VERSION="3.7.4"
GAL_VERSION="0.2.1"

## Set up target install directory
TGT_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
[ -d "${TGT_DIR}" ] || mkdir -p "$TGT_DIR"

## Build environment configuration
build_os=$(uname -s)
build_arch=$(uname -m)
[ "$BB_ARCH_FLAGS" == "<UNDEFINED>" ] && BB_ARCH_FLAGS=
[ "$BB_OPT_FLAGS" == "<UNDEFINED>" ] && BB_OPT_FLAGS=
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ] && BB_MAKE_JOBS=1
CFLAGS="${CFLAGS} ${BB_ARCH_FLAGS} ${BB_OPT_FLAGS}"
CFLAGS="${CFLAGS} -fsigned-char"
CFLAGS="${CFLAGS} -I${PREFIX}/include"
CXXFLAGS="${CFLAGS}"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS CXXFLAGS LDFLAGS

# Needed to help certain supplemental build tools that are themselves built
# from source along, especially on OS X (e.g., MakeDepends used by Chrysalis).
if [ "$build_os" == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi


## Build and install core components
cp -fvp "${SRC_DIR}/Trinity" "${TGT_DIR}/Trinity"
sed -i.bak "s:@@INSTALL_DIR@@:${TGT_DIR}:g" "${TGT_DIR}/Trinity"
rm -f "${TGT_DIR}/Trinity.bak"

make -j${BB_MAKE_JOBS} inchworm_target TRINITY_COMPILER=gnu \
    INCHWORM_CONFIGURE_FLAGS="CXX='${CXX}' CXXFLAGS='${CXXFLAGS}'" \
    INCHWORM_PREFIX="${TGT_DIR}/Inchworm"
cp -fv "${SRC_DIR}/Inchworm/README" "${TGT_DIR}/Inchworm"

make -j${BB_MAKE_JOBS} chrysalis_target TRINITY_COMPILER=gnu \
    SYS_OPT="" SYS_LIBS="-pthread"
[ -d "${TGT_DIR}/Chrysalis" ] && rm -rf "${TGT_DIR}/Chrysalis"
cp -Rf "${SRC_DIR}/Chrysalis" "${TGT_DIR}/Chrysalis"
cd "${TGT_DIR}/Chrysalis"
rm -f ReadsToComponents.pl; mv -f analysis/ReadsToComponents.pl .
rm -rf *.cc aligns analysis base obj system util Makefile* MakeDepend*
cd "${SRC_DIR}"

mkdir -p "${TGT_DIR}/Butterfly"
cp -fvp "${SRC_DIR}/Butterfly"/*.jar "${TGT_DIR}/Butterfly"
cp -fvp "${SRC_DIR}/Butterfly"/*.zip "${TGT_DIR}/Butterfly"

## Install perl libraries and other utilities
[ -d "${TGT_DIR}/PerlLib" ] && rm -rf "${TGT_DIR}/PerlLib"
cp -Rf "${SRC_DIR}/PerlLib" "${TGT_DIR}/PerlLib"
find "${TGT_DIR}/PerlLib" -type f \
    ! -name '*.pm' ! -name '*.pl' ! -name '*.ph' \
    -exec rm -f {} \;

[ -d "${TGT_DIR}/util" ] && rm -rf "${TGT_DIR}/util"
cp -Rf "${SRC_DIR}/util" "${TGT_DIR}/util"
rm -rf "${TGT_DIR}/util/PBS"

## Build the jellyfish plugin
cd "${SRC_DIR}/trinity-plugins"
JELLYFISH_SRC="jellyfish-${JELLYFISH_VERSION}"
if [ -d ${JELLYFISH_SRC} ]; then
    echo "removing old jellyfish build" >&2
    rm -rf ${JELLYFISH_SRC}
fi
if [ "$build_arch" == ppc64le ]; then
    JELLYFISH_OPTS="--without-int128 --without-sse"
else
    JELLYFISH_OPTS="--with-int128 --with-sse"
fi
tar -xzf ${JELLYFISH_SRC}.tar.gz
cd ${JELLYFISH_SRC}
cp -f "${PREFIX}/share/autoconf/config.guess" ./config.guess
cp -f "${PREFIX}/share/autoconf/config.sub" ./config.sub
patch -b -p0 < "${RECIPE_DIR}/jellyfish-srcs.patch"
env CC="gcc" CXX="g++" \
    ./configure \
    --prefix="${TGT_DIR}/trinity-plugins/jellyfish" \
    --enable-static --disable-shared \
    ${JELLYFISH_OPTS} \
    2>&1 | tee jellyfish-configure.log
make -j${BB_MAKE_JOBS} V=1 \
    LDFLAGS="${LDFLAGS} -lpthread" \
    AM_CPPFLAGS="-std=c++11 -Wall -Wnon-virtual-dtor -I"`pwd`"/include"
make install-strip
rm -rf "${TGT_DIR}/trinity-plugins/jellyfish/lib" \
    "${TGT_DIR}/trinity-plugins/jellyfish/include" \
    "${TGT_DIR}/trinity-plugins/jellyfish/share"

## Build and install the fastool plugin
cd "${SRC_DIR}/trinity-plugins/${FASTOOL_VERSION}"
make clean
make CFLAGS="${CFLAGS} -std=c99 -Werror"
install -d "${TGT_DIR}/trinity-plugins/fastool"
install -m 0755 fastool "${TGT_DIR}/trinity-plugins/fastool"

## Build and install the parafly plugin
cd "${SRC_DIR}/trinity-plugins/parafly-code"
[ -f Makefile ] && make distclean
patch -b -p2 < "${RECIPE_DIR}/parafly-configure.patch"
./configure --prefix="${TGT_DIR}/trinity-plugins/parafly" \
    CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
make -j${BB_MAKE_JOBS}
make install

## Build and install the scaffold_iworm_contigs plugin
cd "${SRC_DIR}/trinity-plugins/scaffold_iworm_contigs"
make clean
make CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS} -lpthread" \
    LIBHTS="${PREFIX}/lib/libhts.a -lz"
install -d "${TGT_DIR}/trinity-plugins/scaffold_iworm_contigs"
install -m 0755 scaffold_iworm_contigs \
    "${TGT_DIR}/trinity-plugins/scaffold_iworm_contigs"

## Install the Trimmomatic plugin
[ -d "${TGT_DIR}/trinity-plugins/Trimmomatic" ] &&
    rm -rf "${TGT_DIR}/trinity-plugins/Trimmomatic"
cp -Rf "${SRC_DIR}/trinity-plugins/Trimmomatic-${TRIMMOMATIC_VERSION}" \
    "${TGT_DIR}/trinity-plugins/Trimmomatic"

## "Cheat" by copying existing samtools, instead of rebuilding from source
# NOTE: have to copy, *NOT* symlink, since the default BioBuilds version of
# samtools is from the 1.x branch and not the 0.1.19 Trinity uses.
install -d "${TGT_DIR}/trinity-plugins/BIN"
install -m 0755 "${PREFIX}/bin/samtools" "${TGT_DIR}/trinity-plugins/BIN"

## Install the slclust plugin
cd "${SRC_DIR}/trinity-plugins/slclust"
make clean
make -j${BB_MAKE_JOBS} LOCAL_CFLAGS="${CXXFLAGS}"
install -d "${TGT_DIR}/trinity-plugins/slclust/bin"
install -m 0755 src/slclust "${TGT_DIR}/trinity-plugins/slclust/bin"

## Install the collectl plugin
cd "${SRC_DIR}/trinity-plugins/collectl"
./build_collectl.sh "collectl-${COLLECTL_VERSION}.src.tar.gz"
find bin -type f -print | xargs chmod u+w
rm -f bin/UNINSTALL
install -d "${TGT_DIR}/trinity-plugins/collectl/bin"
cp -Rf bin/. "${TGT_DIR}/trinity-plugins/collectl/bin"

## Install the fasta_tool (GAL) plugin
install -d "${TGT_DIR}/trinity-plugins/GAL_${GAL_VERSION}"
install -m 0755 "${SRC_DIR}/trinity-plugins/GAL_${GAL_VERSION}/fasta_tool" \
     "${TGT_DIR}/trinity-plugins/GAL_${GAL_VERSION}"

## Other things to clean up
chmod a+x "${TGT_DIR}/util/support_scripts/trinity_install_tests.sh"
chmod a+x "${TGT_DIR}/util/support_scripts/plugin_install_tests.sh"

## Create useful symlink
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"
cd "${PREFIX}/bin"
ln -sf "../share/${PKG_NAME}-${PKG_VERSION}/Trinity" Trinity

#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Hard-limit on the parallelism Boost's build system supports
[[ "${MAKE_JOBS}" -gt 64 ]] && MAKE_JOBS=64

# Platform-specific tweaks
case "${HOST_OS}" in
    "darwin")
        boost_toolset=clang

        # Using libc++ instead of libstdc++ to make our Boost package usable with
        # C++11 applications (see comments in "boost/1.60.build.sh" for details).
        #CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
        #LDFLAGS="${LDFLAGS} -stdlib=libc++"
        ;;
    "linux")
        boost_toolset=gcc
        ;;
    *)
        echo "FATAL: unsupported operating system '${HOST_OS}'" >&2
        exit 1;
        ;;
esac

#-----------------------------------------------------------------------------
# Libraries needing separate building and installation in this Boost version:
#   - atomic
#   - chrono
#   - container
#   - context
#   - contract
#   - coroutine
#   - date_time
#   - exception
#   - fiber
#   - filesystem
#   - graph
#   - graph_parallel
#   - iostreams
#   - locale
#   - log
#   - math
#   - mpi
#   - program_options
#   - python
#   - random
#   - regex
#   - serialization
#   - stacktrace
#   - system
#   - test
#   - thread
#   - timer
#   - type_erasure
#   - wave
#-----------------------------------------------------------------------------

# Use the "cc" toolset so `bootstrap.sh` uses `$CXX` to build `bjam`.
# Annoyingly, `bjam` itself can't use `$CXX` to build the Boost libraries;
# that's a long standing bug that results in an "cc.jam: No such file or
# directory" error. See <https://svn.boost.org/trac10/ticket/5917>
./bootstrap.sh \
    --with-toolset="cc" \
    --prefix="${PREFIX}" \
    --libdir="${PREFIX}/lib" \
    --with-icu="${PREFIX}" \
    --without-libraries=graph_parallel,mpi,python
    2>&1

# Work-around the "cc" toolset bug mentioned from above
sed -i.bak "s|cc|${boost_toolset}|g" project-config.jam

# Tell bjam where to find the conda C++ compiler
# See: <https://stackoverflow.com/a/5346531>
cat  <<EOF >tools/build/src/user-config.jam
using ${boost_toolset} : conda : ${CXX} ;
EOF

# Finally, we can build Boost...
./bjam -q -d0 \
    toolset="${boost_toolset}-conda" \
    cflags="${CFLAGS}" \
    cxxflags="${CXXFLAGS}" \
    linkflags="${LDFLAGS}" \
    variant=release \
    debug-symbols=off \
    link=static,shared \
    runtime-link=shared \
    address-model=64 \
    threading=multi \
    --layout=system \
    --prefix="${PREFIX}" \
    -j${MAKE_JOBS} \
    install 2>&1 | tee build.log

# Remove headers for components we don't currently support
rm -rf "${PREFIX}/include/boost/mpi.hpp" "${PREFIX}/include/boost/mpi"
rm -rf "${PREFIX}/include/boost/python.hpp" "${PREFIX}/include/boost/python"

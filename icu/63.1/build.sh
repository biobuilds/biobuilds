#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Platform-specific tweaks
case "${HOST_OS}" in
    "darwin")
        # WARNING: using "libc++" instead of "libstdc++" as our C++ stdlib breaks
        # compatibility with the "defaults" channel's ICU package. However, to make
        # our OS X boost packages usable with C++11 applications, we need to link
        # to use "libc++" (see comments in boost/1.60/build.sh for details).
        #CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
        #LDFLAGS="${LDFLAGS} -stdlib=libc++"
        ;;
    "linux")
        ;;
    *)
        echo "unsupported host OS '${HOST_OS}'" >&2
        exit 1
        ;;
esac

# Options passed to `./configure`
declare -a cfg_opts
cfg_opts=()
cfg_opts+=(--enable-release)        # release libraries
cfg_opts+=(--disable-debug)         # debug libraries
cfg_opts+=(--disable-tracing)       # function and data tracing

cfg_opts+=(--enable-shared)         # shared libraries
cfg_opts+=(--enable-static)         # static libraries
cfg_opts+=(--with-library-bits=64)  # build 64-bit libraries
cfg_opts+=(--disable-auto-cleanup)  # auto cleanup of libraries
cfg_opts+=(--enable-draft)          # draft (and internal) APIs
cfg_opts+=(--enable-renaming)       # add version suffix to symbols
cfg_opts+=(--enable-rpath)          # set rpath when linking

cfg_opts+=(--disable-extras)        # extras (e.g., uconv); requires dev tools
cfg_opts+=(--enable-icu-config)     # install `icu-config`
cfg_opts+=(--enable-icuio)          # icuio library
cfg_opts+=(--disable-layoutex)      # paragraph layout lib; requires harfbuzz
cfg_opts+=(--disable-plugins)       # plugin support
cfg_opts+=(--disable-samples)       # samples
cfg_opts+=(--disable-tools)         # ICU development tools
cfg_opts+=(--disable-tests)         # tests

# Package ICU data as a single shared library (.so or .dylib); this is the
# option that's simplest and the least likely to break Other People's Code.
# See <http://userguide.icu-project.org/icudata> for details.
cfg_opts+=(--with-data-packaging=library)

# Configure, build, and install the C/C++ libraries
set -o pipefail

cd source
./configure --prefix="$PREFIX" \
    ${cfg_opts[@]} \
    2>&1 | tee configure.log
make -j${MAKE_JOBS} ${VERBOSE_AT}
make install

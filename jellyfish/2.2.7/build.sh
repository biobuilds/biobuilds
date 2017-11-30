#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v


## Configure
case "$BUILD_ARCH" in
    "ppc64le")
        CFLAGS="${CFLAGS} -fsigned-char"
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ;;
esac

declare -a new_flags
if [[ "$CXX" == */icpc ]]; then
    # Disable CPU auto-dispatch as it's causing linking of the `jellyfish`
    # executable to fail with a "hidden symbol `__intel_cpu_features_init' in
    # libirc.a(cpu_feature_disp.o) is referenced by DSO" error.
    for var in CFLAGS CXXFLAGS; do
        new_flags=()
        for flag in ${!var}; do
            case $flag in
                -ax*) ;;
                *) new_flags+=($flag) ;;
            esac
        done
        eval ${var}="\${new_flags[@]}"
        export ${var}
    done

    # Use conda's updated g++ so `icpc` has proper C++11 support.  Having
    # `icpc` behave like g++-4.4 (our default x86_64 compiler) leads to
    # various compiler errors.
    CFLAGS="${CFLAGS} -gcc-name=${CONDA_CC}"
    CXXFLAGS="${CXXFLAGS} -gcc-name=${CONDA_CC}"
    CXXFLAGS="${CXXFLAGS} -gxx-name=${CONDA_CXX}"
fi

# Options to pass to `./configure`
declare -a configure_opts

# Just in case someone wants to use this to build shared libraries
configure_opts+=(--with-pic)

# We don't have a swig package available for all platforms at the moment, so
# we'll disable scripting language support for now.
configure_opts+=(--disable-swig)
configure_opts+=(--disable-all-binding)
configure_opts+=(--disable-perl-binding)
configure_opts+=(--disable-python-binding)
configure_opts+=(--disable-ruby-binding)

# This option causes `./configure` to set compiler instruction set flags
# (-msse4.2, -mavx, -mavx2, etc.) based on the instruction sets supported by
# the build host's CPU. Since not all target (i.e., end-user) computers will
# have the same support, we should avoid the "--with-sse" option.
configure_opts+=(--without-sse)

# Not sure if this fully works on all the architectures we support, so disable
# this until we've had a chance to fully test it.
configure_opts+=(--without-int128)

# Make extra sure `./configure` can see these environment variables
export CC CFLAGS CXX CXXFLAGS
export AR LD LDFLAGS

./configure --prefix="${PREFIX}" \
    "${configure_opts[@]}"
    2>&1 | tee configure.log


## Build
make -j${MAKE_JOBS} ${VERBOSE_AT} \
    LD="${LD}" \
    2>&1 | tee build.log


## Install
make install ${VERBOSE_AT}

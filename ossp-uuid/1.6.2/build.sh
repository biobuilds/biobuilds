#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Update these files to support building on newer platforms (e.g., ppc64le)
cp -fv "${BUILD_PREFIX}/share/autoconf/config.guess" config.guess
cp -fv "${BUILD_PREFIX}/share/autoconf/config.sub" config.sub

# WARNING: Do NOT add `--disable-debug` or `--without-dmalloc` below. Due to
# quirks in `./configure`, doing so will _enable_ these features, even if the
# command line argument says otherwise. In particular, `--disable-debug` will
# disable building of shared libraries, even when `--enable-shared` is used.
declare -a config_opts
#config_opts+=(--enable-debug)           # debugging symbols
config_opts+=(--enable-static)          # static libraries
config_opts+=(--enable-shared)          # shared libraries
config_opts+=(--with-pic)               # build position-independent code
#config_opts+=(--with-dmalloc)           # use external Dmalloc library
config_opts+=(--without-dce)            # DCE 1.1 backward compatibility API
config_opts+=(--without-cxx)            # C++ bindings
config_opts+=(--without-perl)           # Perl bindings
config_opts+=(--without-perl-compat)    # Perl compatibility API
config_opts+=(--without-php)            # PHP bindings
config_opts+=(--without-pgsql)          # PostgreSQL bindings

# The usual build steps...
./configure --prefix="${PREFIX}" \
    --includedir="${PREFIX}/include/ossp" \
    "${config_opts[@]}" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} ${VERBOSE_AT} \
    2>&1 | tee build.log

make check

make install

# Tweak installed file names to match our library rename. (We're renaming the
# library to `libossp-uuid` to avoid any potential conflicts with other
# packages [e.g., `e2fsprogs`] that may provide a UUID library.)
mv "${PREFIX}/share/man/man3/uuid.3" "${PREFIX}/share/man/man3/uuid.3ossp"
mv "${PREFIX}/lib/pkgconfig/uuid.pc" "${PREFIX}/lib/pkgconfig/ossp-uuid.pc"

# Extract the license text into its own file for `conda-build` to find
sed -n '32,54s/^[[:space:]]*//p' README > LICENSE

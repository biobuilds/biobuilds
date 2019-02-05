#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

declare -a config_opts

# Build only the component(s) we're interested in
config_opts+=(--disable-all-programs)
config_opts+=(--disable-bash-completion)
config_opts+=(--disable-colors-default)
config_opts+=(--enable-libuuid)

# Standard set of options we use for building libraries
config_opts+=(--enable-rpath)
config_opts+=(--enable-shared)
config_opts+=(--enable-static)
config_opts+=(--with-pic)

# Force symbol versioning
#config_opts+=(--enable-symvers)

# These shouldn't really matter for the components we've selected, but just in
# case, don't chown or make the applications setuid/setgid when installing.
config_opts+=(--disable-makeinstall-chown)
config_opts+=(--disable-makeinstall-setuid)

# Stop `./configure` from looking for various libraries; this prevents our
# build from accidentally picking up dependencies due to other development
# packages being installed on the build servers.
config_opts+=(--disable-nls)
config_opts+=(--without-libiconv-prefix)
config_opts+=(--without-libintl-prefix)
config_opts+=(--without-ncurses)
config_opts+=(--without-ncursesw)
config_opts+=(--without-readline)
config_opts+=(--without-tinfo)
config_opts+=(--without-libz)
config_opts+=(--without-python)
config_opts+=(--without-selinux)
config_opts+=(--without-systemd)

./configure --prefix="${PREFIX}" \
    "${config_opts[@]}" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} ${VERBOSE_AT} \
    2>&1 | tee build.log

make install

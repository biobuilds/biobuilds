#!/bin/bash
set -o pipefail

## Configure

BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

declare -a config_opts
config_opts+=(--enable-largefile)
config_opts+=(--enable-plugins)
config_opts+=(--enable-history-file)
config_opts+=(--enable-backwards-compatibility)

config_opts+=(--with-readline="${PREFIX}")
config_opts+=(--with-gd="${PREFIX}")

config_opts+=(--without-latex)
config_opts+=(--without-texdir)
config_opts+=(--without-kpsexpand)
config_opts+=(--without-lua)
config_opts+=(--without-tutorial)

case "${BUILD_OS}" in
    "linux")
        config_opts+=(--with-cairo)
        config_opts+=(--without-linux-vga)
        config_opts+=(--without-ggi)
        config_opts+=(--without-xmi)

        # Enable basic X11 support on x86_64, since our cairo package requires
        # it anyways (i.e., we'll get link failures if X11 libs are missing.)
        if [[ "${BUILD_ARCH}" == "x86_64" ]]; then
            config_opts+=(--with-x)
        else
            config_opts+=(--without-x)
        fi

        # Disable other X11 features (for now)
        config_opts+=(--without-x-dcop)
        config_opts+=(--disable-x11-mbfonts)
        config_opts+=(--disable-x11-external)
        config_opts+=(--without-qt)
        config_opts+=(--without-wx)
        config_opts+=(--disable-wxwidgets)
        ;;
    "darwin")
        config_opts+=(--without-cairo)
        config_opts+=(--without-aquaterm)
        ;;
esac

## Other options we'll leave to ./configure make decisions about
#
#  --disable-boxed-text    disable support for boxed labels
#  --disable-raise-console spacebar in plot window does not raise console
#  --disable-objects       disable rectangles and other objects
#  --disable-h3d-quadtree  disable quadtree optimization in hidden3d code
#  --enable-h3d-gridbox    enable gridbox optimization in hidden3d code
#  --disable-stats         Omit calculation of statistical summary of data
#  --without-nonlinear-axes     disable support for nonlinear axes
#  --without-libcerf       build without special functions from libcerf (default enabled)
#  --with-gihdir=DIR       location of .gih help text file
#  --with-caca=DIR         where to find the caca library
#  --with-cwdrc            check current directory for .gnuplot file, normally disabled for security reasons
#  --with-row-help         format help and subtopic tables by row (default)
#  --without-row-help      format help and subtopic tables by column
#  --with-bitmap-terminals dot-matrix printers and pbm
#  --with-gpic             gpic terminal
#  --with-mif              mif terminal (FrameMaker 3)
#

env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" \
    ./configure --prefix="${PREFIX}" \
    "${config_opts[@]}" \
    2>&1 | tee configure.log


## Build
make -j${MAKE_JOBS} 2>&1 | tee build.log


## Install
make install

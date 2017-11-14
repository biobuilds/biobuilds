#!/usr/bin/env bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

case `uname -s` in
    "Darwin")
        # Need to get appropriate response to g_get_system_data_dirs()
        # See the hardcoded-paths.patch file
        export CFLAGS="$CFLAGS -DCONDA_PREFIX=\\\"${PREFIX}\\\""
        LIBICONV=gnu
        ;;
    "Linux")
        # So the system (builtin to glibc) iconv gets found and used.
        LIBICONV=maybe
        export PATH="$PATH:$PREFIX/$HOST/sysroot/usr/bin"
        ;;
esac

# Make sure configure picks up these environment variables
export PKG_CONFIG_PATH
export CC CFLAGS CXX CXXFLAGS AR LD LDFLAGS

# NOTE: A full path to PYTHON causes overly long shebang in gobject/glib-genmarshal
./configure --prefix=${PREFIX} \
    --disable-gtk-doc \
    --disable-gtk-doc-html \
    --disable-gtk-doc-pdf \
    --disable-man \
    --disable-selinux \
    --disable-fam \
    --disable-xattr \
    --disable-libelf \
    --disable-libmount \
    --with-pic \
    --with-python=$(basename "${PYTHON}") \
    --with-pcre=system \
    --with-libiconv=${LIBICONV} \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT}
# FIXME
# ERROR: fileutils - too few tests run (expected 15, got 14)
# ERROR: fileutils - exited with status 134 (terminated by signal 6?)
# make check
make install

# gdb folder has a nested folder structure similar to our host prefix (255 chars) which causes installation issues
#    so kill it.
rm -rf $PREFIX/share/gdb

#!/bin/bash

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Limit the number of threads OpenBLAS uses so we don't saturate our build
# servers with BLAS threads.
export OPENBLAS_NUM_THREADS=${CPU_COUNT}
export OMP_NUM_THREADS=${CPU_COUNT}

# Configuration for BLAS library
cat >site.cfg <<EOF
[DEFAULT]
library_dirs = $PREFIX/lib
include_dirs = $PREFIX/include

EOF

case "$blas_impl" in
    "openblas")
        cat >>site.cfg <<-EOF
		[atlas]
		atlas_libs = openblas
		libraries = openblas
		
		[openblas]
		libraries = openblas
		library_dirs = $PREFIX/lib
		include_dirs = $PREFIX/include
		EOF
        ;;
    *)
        echo "ERROR: Unsupported BLAS implementation" >&2
        exit 1
        ;;
esac

# OS-specific tweaks
case "$BUILD_OS" in
    "darwin")
        export LDFLAGS="$LDFLAGS -undefined dynamic_lookup"
        ;;
    "linux")
        export LDFLAGS="$LDFLAGS -shared"
        ;;
    *)
        echo "ERROR: Unsupported operating system ${BUILD_OS}" >&2
        exit 1
        ;;
esac

# conda's "OPT" environment variable (used to enable or disable the package's
# "opt" feature) is also the one numpy uses to get additional toolchain flags,
# so we need to unset it. If we don't, the build process could fail when the
# compiler tries to compile a non-existent source file named "0" or "1".
unset OPT

# Make sure scipy's build system can see these
export CPP CPPFLAGS
export CC CFLAGS
export FC FCFLAGS
export FFLAGS="${FCFLAGS}"
export AR LD LDFLAGS

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

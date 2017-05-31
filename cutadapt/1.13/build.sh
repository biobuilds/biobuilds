#!/bin/bash

## Compile configuration

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Just in case, make sure that compilers on different platforms assume the same
# signedness for plain 'char'. (Signed chars is default for x86_64 gcc.)
CFLAGS="${CFLAGS} -fsigned-char"

# Need this to prevent the "import .utils" statement in various test scripts
# from triggering an "Attempted relative import in non-package" exception.
touch tests/__init__.py

# Run built-in tests before packaging to make sure our choices for compiler and
# linker flags don't break anything
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    "$PYTHON" setup.py build_ext -i
nosetests

# Build and install the package
env CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
    "$PYTHON" setup.py install

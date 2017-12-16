#!/bin/bash

set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Build configuration is done largely by #define-s
declare -a configure_opts make_opts
configure_opts+=(-DUNIX)                # Building for a UNIX-like platform
configure_opts+=(-DWILD_STOP_AT_DIR)    # Add "-W" option so wildcards do not match directories
configure_opts+=(-DDATE_FORMAT=DF_YMD)  # Dates in ISO-8601 format or bust
configure_opts+=(-DACORN_FTYPE_NFS)     # Add "-F" option to handle RiscOS extra file info
configure_opts+=(-DSFX_EXDIR)           # Add "-d" option to extract to prefix directory
configure_opts+=(-DUNIXBACKUPS)         # Add "-B" option to prevent file squashing
configure_opts+=(-DUSE_DEFLATE64)       # Support newer "deflate64" algorithm
configure_opts+=(-DUSE_CRYPT)           # Support decryption in all binaries
configure_opts+=(-DUNICODE_SUPPORT)     # Support UTF-8 encoded paths using the next 2 options
configure_opts+=(-DUTF8_MAYBE_NATIVE)   # If avaiable, use the system's native UTF-8 encoding
configure_opts+=(-DUNICODE_WCHAR)       # Use wide character encoding if no native UTF-8 support
configure_opts+=(-D_MBCS)               # Support multi-byte character sets
configure_opts+=(-DNO_WORKING_ISPRINT)  # Disable enhanced filtering for non-printable characters
                                        # in filenames so UTF-8 filenames display correctly; see:
                                        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=682682
configure_opts+=(-DLARGE_FILE_SUPPORT)  # Support for files > 4-GiB
configure_opts+=(-DNO_LCHMOD)           # Linux and macOS do not have an lchmod(2) system call
configure_opts+=(-DIZ_HAVE_UXUIDGID)    # Needed so "-X" option properly restore UIDs/GIDs; see:
                                        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=689212
configure_opts+=(-DNOMEMCPY)            # Disable memcpy(2) to avoid data corruption; see:
                                        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=694601
configure_opts+=(-DHAVE_DIRENT_H)       # Have the POSIX directory traversal header
configure_opts+=(-DHAVE_TERMIOS_H)      # Have the POSIX terminal I/O header

# Enable bzip2 support; the "defaults" and "BioBuilds" packages both have a
# "run_export" directive that automatically includes them as a run dependency,
# so we might as well go ahead and dynamically link to libbz2.
configure_opts+=(-DUSE_BZIP2)
make_opts+=(D_USE_BZ2=-DUSE_BZIP2)
make_opts+=(L_BZ2=-lbz2)

CFLAGS="${CFLAGS} ${configure_opts[@]}"

# Restore certain CFLAGS we squash by passing in our own
CFLAGS="${CFLAGS} -I. -Wall"

make -f unix/Makefile unzips \
    CC="${CC}" CF="${CFLAGS}" LF2="${LDFLAGS}" \
    "${make_opts[@]}"

make -f unix/Makefile install prefix="${PREFIX}"
rm -rf "${PREFIX}/man"

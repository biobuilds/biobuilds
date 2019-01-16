#!/bin/bash
set -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Platform-specific tweaks
case "${HOST_OS}" in
    "linux")
        export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
        ;;
    "darwin")
        export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
        ;;
    *)
        echo "FATAL: unsupported operating system '${HOST_OS}'" >&2
        exit 1
        ;;
esac

case "${HOST_ARCH}" in
    "x86_64")
        ;;
    "ppc64le")
        ;;
    *)
        echo "FATAL: unsupported operating system '${HOST_OS}'" >&2
        exit 1
        ;;
esac

declare -a config_opts

# What to build
config_opts+=(--enable-shared)          # shared libraries (.so/.dylib)
config_opts+=(--enable-static)          # static libraries (.a)
config_opts+=(--without-minimum)        # target minimally-sized libraries
config_opts+=(--with-pic)               # position-independent code

# Turn off debugging support
config_opts+=(--without-debug)          # debugging module
config_opts+=(--without-mem-debug)      # memory debugging module
config_opts+=(--without-run-debug)      # runtime debugging module
config_opts+=(--without-coverage)       # GCC code coverage (gcov) support

# Internationalization
config_opts+=(--with-icu)
config_opts+=(--with-iconv)
config_opts+=(--with-iso8859x)          # Use ISO8859X as an iconv fallback

# Network access
config_opts+=(--enable-ipv6)
config_opts+=(--with-ftp)
config_opts+=(--with-http)

# Compression
config_opts+=(--with-zlib)
config_opts+=(--with-lzma)

# Language bindings
config_opts+=(--without-python)
config_opts+=(--without-fexceptions)    # GCC flag for C++ exception support

# Library features
config_opts+=(--with-c14n)              # canonicalization support
config_opts+=(--with-catalog)           # catalog support
config_opts+=(--with-docbook)           # Docbook SGML support
config_opts+=(--with-history)           # history support in xmllint shell
config_opts+=(--with-html)              # HTML support
config_opts+=(--with-legacy)            # deprecated APIs for compatibility
config_opts+=(--with-modules)           # dynamic modules support
config_opts+=(--with-output)            # serialization support
config_opts+=(--with-pattern)           # xmlPattern selection interface
config_opts+=(--with-push)              # PUSH parser interfaces
config_opts+=(--with-reader)            # xmlReader parsing interface
config_opts+=(--with-readline)          # readline support in xmllint shell
config_opts+=(--with-regexps)           # regular expressions support
config_opts+=(--with-sax1)              # older SAX1 interface
config_opts+=(--with-schemas)           # Relax-NG and Schemas support
config_opts+=(--with-schematron)        # Schematron support
config_opts+=(--with-threads)           # multithread support
config_opts+=(--without-thread-alloc)   # per-thread memory allocation
config_opts+=(--with-tree)              # DOM-like tree manipulation APIs
config_opts+=(--with-valid)             # DTD validation support
config_opts+=(--with-writer)            # xmlWriter saving interface
config_opts+=(--with-xinclude)          # XInclude support
config_opts+=(--with-xpath)             # XPATH support
config_opts+=(--with-xptr)              # XPointer support

#./autogen.sh

./configure --prefix="${PREFIX}" \
    "${config_opts[@]}" \
    2>&1 | tee configure.log

make -j${CPU_COUNT} ${VERBOSE_AT} \
    2>&1 | tee build.log

eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" \
    make check ${VERBOSE_AT} \
    2>&1 | tee check.log

make install

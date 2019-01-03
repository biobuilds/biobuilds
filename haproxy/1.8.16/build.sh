#!/bin/bash

##-----------------------------------------------------------------------------
## Configure
##-----------------------------------------------------------------------------

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment  configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Set certain flags based on target platform
case "$HOST_ARCH" in
    "x86_64")
        HOST_IS_X64=1
        ;;
    *)
        HOST_IS_X64=
        ;;
esac

case "$HOST_OS" in
    "linux")
        TARGET="linux2628"
        HOST_IS_LINUX=1
        HOST_IS_MACOS=
        ;;
    "darwin")
        TARGET="osx"
        HOST_IS_LINUX=
        HOST_IS_MACOS=1
        ;;
    *)
        echo "FATAL: Unsupport operating system '$HOST_OS'" >&2
        exit 1
        ;;
esac

declare -a build_opts

# Enable basic features
build_opts+=(USE_POLL=1)            # poll() fallback
build_opts+=(USE_THREAD=1)          # threaded operation
build_opts+=(USE_GETADDRINFO=1)     # getaddrinfo(3) for IPv6 name resolution

# Enable x86 optimizations, as appropriate
build_opts+=(USE_REGPARM=${HAPROXY_X64})

# For Linux builds, assume we can safely use features that require Linux
# kernels >= 2.6.24 and/or glibc >= 2.10. Not a terribly unreasonable
# assumption, since the oldest distribution we support (CentOS/RHEL 6) comes
# with Linux kernel 2.6.32 and glibc 2.12.
build_opts+=(USE_ACCEPT4=${HOST_IS_LINUX})
build_opts+=(USE_MY_ACCEPT4=)

build_opts+=(USE_EPOLL=${HOST_IS_LINUX})
build_opts+=(USE_MY_EPOLL=)

build_opts+=(USE_FUTEX=${HOST_IS_LINUX})
build_opts+=(USE_LINUX_SPLICE=${HOST_IS_LINUX})

build_opts+=(USE_MY_SPLICE=)
build_opts+=(USE_NETFILTER=${HOST_IS_LINUX})

# Network namespace support requires the `setns(3)`, which appeared in Linux
# kernel 3.0 and glibc 2.14. Therefore, it cannot be used on the oldest Linux
# distribution we support (CentOS/RHEL 6).
#
# ** WARNING **: the HAProxy build documentation incorrectly states this
# capability is supported Linux kernels >= 2.6.24.
build_opts+=(USE_NS=)

# TCP fast open support requires Linux kernel >= 3.7, so we cannot safely
# enable it. NOTE: the build still succeeds on older systems, but the resulting
# binary will fail to run on unsupported systems.
build_opts+=(USE_TFO=)

# Enable transparent proxy support
#
# NOTE: (Full) transparent proxy support may require a custom Linux kernel
# and/or additional firewall rules, but that's on the user to configure.
build_opts+=(USE_TPROXY=1)
build_opts+=(USE_LINUX_TPROXY=${HOST_IS_LINUX})

# CPU pinning requires Linux-specific system calls (e.g., `sched_setaffinity`).
# Enabling this feature on other platforms (e.g., macOS) will lead to various
# undeclared symbol errors.
build_opts+=(USE_CPU_AFFINITY=${HOST_IS_LINUX})

# libcrypt is part of glibc, so using it to support encrypted passwords on
# Linux should be a safe choice.
build_opts+=(USE_LIBCRYPT=${HOST_IS_LINUX})

# Enable BSD's kqueue() on macOS
build_opts+=(USE_KQUEUE=${HOST_IS_MACOS})

# Use zlib, not slz, for HTTP compression. Note that these are mutually
# exclusive options.
build_opts+=(USE_ZLIB=1)
build_opts+=(USE_SLZ=)

# Use static libpcre (*not* libpcre2) for regex; this is decision is driven
# mostly by the fact that we already have a pcre package, but no pcre2 one.
build_opts+=(USE_PCRE=1)
build_opts+=(USE_PCRE_JIT=1)
build_opts+=(USE_STATIC_PCRE=)

build_opts+=(USE_PCRE2=)
build_opts+=(USE_PCRE2_JIT=)
build_opts+=(USE_STATIC_PCRE2=)

build_opts+=(PCREDIR="${PREFIX}")
build_opts+=(PCRE_INC="${PREFIX}/include")
build_opts+=(PCRE_LIB="${PREFIX}/lib")

# Enable use of OpenSSL. Recommended, but see below.
build_opts+=(USE_OPENSSL=1)
build_opts+=(SSL_INC="${PREFIX}/include")
build_opts+=(SSL_LIB="${PREFIX}/lib")

# Enable SSL session cache sharing among processes; this prevents
# multiple renegotiations due to clients hitting a different process.
build_opts+=(USE_PRIVATE_CACHE=)

# Enable pthreads for atomic and sync operations on the SSL cache
build_opts+=(USE_PTHREAD_PSHARED=1)

# Disable miscellaneous features
build_opts+=(USE_DLMALLOC=)         # dlmalloc (alternative memory allocator)
build_opts+=(USE_VSYSCALL=)         # use `vsyscall` to bypass glibc (x86 Linux)
build_opts+=(USE_SYSTEMD=)          # sd_notify() support
build_opts+=(USE_LUA=)              # Lua support

# Disable 3rd-party device detection libraries
build_opts+=(USE_DEVICEATLAS=)
build_opts+=(USE_51DEGREES=)
build_opts+=(USE_WURFL=)

# Our build systems seem to do fine automatically setting these
# options, so we'll just leave them alone.
#build_opts+=(USE_CRYPT_H)           # System requires including <crypt.h>
#build_opts+=(USE_DL)                # System requires `-ldl`


##-----------------------------------------------------------------------------
## Build
##-----------------------------------------------------------------------------
make clean

make -j${MAKE_JOBS} \
    CC="${CC}" CFLAGS="${CFLAGS}" \
    LD="${CC}" LDFLAGS="${LDFLAGS}" \
    PREFIX="${PREFIX}" \
    TARGET="${TARGET}" \
    ARCH="64" \
    ${build_opts[@]}

##-----------------------------------------------------------------------------
## Install
##-----------------------------------------------------------------------------

umask 022
make -j${MAKE_JOBS} \
    PREFIX="${PREFIX}" \
    SBINDIR="${PREFIX}/bin" \
    DOCDIR="${PREFIX}/share/doc/${PKG_NAME}-${PKG_VERSION}" \
    install

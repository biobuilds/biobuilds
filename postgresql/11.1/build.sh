#!/bin/bash
set -e -o pipefail

# Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

declare -a config_opts

# Tell the build system where to find things
config_opts+=(--with-includes="${PREFIX}/include")
config_opts+=(--with-libraries="${PREFIX}/lib")

# Embed the shared libraries search path in executables. Theoretically, `conda
# build` should be able add relocation magic even if we don't use this option.
# However, without it, the binary resizing that's done to support package
# relocation can trigger run-time failures on certain target (host) platforms.
config_opts+=(--enable-rpath)

# Turn off options for developing or debugging PostgreSQL itself
config_opts+=(--disable-debug)      # debugging symbols
config_opts+=(--disable-cassert)    # assertion checks
config_opts+=(--disable-coverage)   # test coverage instrumentation
config_opts+=(--disable-dtrace)     # DTrace support
config_opts+=(--disable-profiling)  # profiling instrumentation

# Other options we really shouldn't need to use, as they are mostly used when
# building for platforms with more limited capabilities.
#config_opts+=(--disable-spinlocks)
#config_opts+=(--disable-atomics)
#config_opts+=(--disable-float4-byval)
#config_opts+=(--disable-float8-byval)

# Disable tests that require Perl TAP tools to run
config_opts+=(--disable-tap-tests)

# Features that should be enabled by default, but these are important enough
# that we want to be _really_ sure they're present.
config_opts+=(--enable-strong-random)
config_opts+=(--enable-thread-safety)

# Large (> 2-GiB) file support. Should automatically be enabled for our target
# platforms, but let's make really sure.
config_opts+=(--enable-largefile)

# Internationalization options
config_opts+=(--enable-nls)         # Native language support
config_opts+=(--with-icu)           # Unicode support

# LLVM-based, server-side JIT support; "beneficial primarily for long-running
# CPU-bound queries", according to the PostgreSQL docs. However, enabling this
# feature would involve including LLVM as a runtime dependency, and that's a
# complication we'd rather not deal with right now.
config_opts+=(--without-llvm)

# Server tuning parameters. Probably best to leave these at their default
# values (indicated within the square brackets below) until we find a _really_
# good reason for changing them.
#config_opts+=(--with-pgport=5432)       # default port number [5432]
#config_opts+=(--with-blocksize=8)       # table block size in KiB [8]
#config_opts+=(--with-segsize=1)         # table segment size in GiB [1]
#config_opts+=(--with-wal-blocksize=8)   # WAL block size in KiB [8]

# Disable the PL/Perl server side language. This feature will probably _never_
# be supported, as it requires a shared libperl that is incompatible with the
# relocatable Perl we distribute.
config_opts+=(--without-perl)

# Disable the PL/Python server side language. We _may_ enable this in the
# future, but since this feature requires a shared libpython, we would have to
# put some work into figuring out how to avoid complete rebuilds of the
# PostgreSQL package(s) while still supporting multiple Python versions.
config_opts+=(--without-python)

# Disable the PL/Tcl server side language to keep the number of runtime
# dependencies down. (We don't know anyone who's actively using this feature.)
config_opts+=(--without-tcl)

# Standard libraries
config_opts+=(--with-libxml)        # SQL/XML
config_opts+=(--with-openssl)       # Encrypted network transport
config_opts+=(--with-readline)      # Command-line history & editing
config_opts+=(--with-zlib)          # Backup/restore compression

# Libraries for add-on modules
config_opts+=(--with-uuid=e2fs)     # UUID generation function
config_opts+=(--with-libxslt)       # XSLT support for older xml2 module

# Use "system" timezone data so we don't have to rebuild and/or upgrade
# PostgreSQL every time (heh) the IANA time zone database changes.
config_opts+=(--with-system-tzdata="${PREFIX}/share/zoneinfo")

# Support for LDAP authentication
config_opts+=(--with-ldap)

# Support for GSSAPI (Kerberos) authentication
config_opts+=(--with-gssapi)
config_opts+=(--with-krb-srvnam=postgres)

# Platform-specific features
case "${HOST_OS}" in
    "darwin")
        # Support for Apple's zeroconf implementation
        config_opts+=(--with-bonjour)
        ;;
    "linux")
        # Disable Bonjour support on Linux, mostly because we don't want to
        # deal with building yet another set of dependencies.
        config_opts+=(--without-bonjour)

        # Disable support for these features because:
        #
        # 1. They involve building dependencies that themselves (may) depend on
        #    "low-level" details (e.g., kernel interfaces) to build correctly.
        #
        # 2. Their use require a level of system integration and administration
        #    that conda environments aren't especially well suited for; users
        #    requiring these features should, instead, install the PostgreSQL
        #    server packages supplied by their OS or other vendor.
        config_opts+=(--without-pam)
        config_opts+=(--without-selinux)
        config_opts+=(--without-systemd)

        # Need this flag, or linking of various applications will fail with
        # undefined symbol errors due to libpq's dependence on libldap_r.
        if [[ "${LDFLAGS}" != *"-Wl,-rpath-link,"* ]]; then
            LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
        fi
        ;;
    *)
        echo "FATAL: unsupported operating system '${HOST_OS}'" >&2
        exit 1
esac

./configure \
    --prefix="${PREFIX}" \
    --datarootdir="${PREFIX}/share" \
    --datadir="${PREFIX}/share/postgresql/" \
    --includedir="${PREFIX}/include/postgresql/" \
    --libdir="${PREFIX}/lib" \
    "${config_opts[@]}" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} ${VERBOSE_AT} \
    2>&1 | tee build.log

make -j${MAKE_JOBS} ${VERBOSE_AT} \
    -C contrib \
    2>&1 | tee build-contrib.log

# Fails with 'initdb: cannot be run as root', so skip checks (for now)
#make check
#make -C contrib check

make install
make -C contrib install

awk '/CATALOG_VERSION_NO/{print $3;}' src/include/catalog/catversion.h \
    >"${PREFIX}/share/postgresql/catalog_version"

if [[ -d "${PREFIX}/share/doc/extension" ]]; then
    mkdir -p "${PREFIX}/share/doc/postgresql"
    mv "${PREFIX}/share/doc/extension" "${PREFIX}/share/doc/postgresql"
fi

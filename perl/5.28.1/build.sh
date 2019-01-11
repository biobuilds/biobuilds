#!/bin/bash
set -o pipefail

## Pull in the common BioBuilds build flags
BUILD_ENV="${BUILD_PREFIX}/share/biobuilds-build/build.env"
if [[ ! -f "${BUILD_ENV}" ]]; then
    echo "FATAL: Could not find build environment configuration script!" >&2
    exit 1
fi
source "${BUILD_ENV}" -v

# Platform-specific tweaks
case "${HOST_OS}" in
    "linux")
        # Linker flags needed to build extension (XS) modules. On Linux, it's
        # no different than creating any other shared library (.so).
        LDDLFLAGS="-shared"

        # We'll need this value to properly configure the Perl build system to
        # use the Anaconda toolchain
        if [[ "$CC_IS_GNU" -eq 1 ]]; then
            : ${CONDA_BUILD_SYSROOT:=$(realpath "`${CC} -print-sysroot`")}
        fi
        ;;
    "darwin")
        # Linker flags needed to build extension (XS) modules. On macOS, we
        # must tell the linker to:
        #
        # 1. Create a bundle (i.e., dynamically loadable module); and
        # 2. Not worry about missing symbols at build time, as those will
        #    likely be provided at run time (i.e., when the bundle/module is
        #    loaded via a `use` or `require` statement)
        #
        # NOTE: leaving off `-undefined dynamic_lookup` will cause module
        # linking to fail with undefined symbol errors for things like
        # `_PL_charclass` and `_PL_op_desc`; these symbols are pretty much
        # guaranteed to be available at run time, but we do need to make the
        # linker aware of that fact.
        #
        # Reference: https://rt.perl.org/Public/Bug/Display.html?id=133752#txn-1604018
        LDDLFLAGS="-bundle -undefined dynamic_lookup"

        # Suppress warnings that clutter up our recipe debugging logs
        CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
        LDFLAGS="${LDFLAGS} -Wno-unused-command-line-argument"

        # Restore (some) key compiler flags squashed by the way we invoke
        # `Configure`; i.e., using `-D*flags` rather than `-A*flags` arguments
        # causes `Configure` to ignore certain platform hints and to not
        # automatically include these flags into the generated Makefiles.
        CFLAGS="-DPERL_DARWIN ${CFLAGS}"
        CFLAGS="-fno-common ${CFLAGS}"
        #CFLAGS="-no-cpp-precomp ${CFLAGS}"
        #CFLAGS="-arch x86_64 ${CFLAGS}"
        ;;
    *)
        echo "FATAL: unsupported operating system '$HOST_OS'" >&2
        exit 1
        ;;
esac


## Set up the list of options we'll pass to './Configure'
declare -a config_opts

# Tell Perl's build & install system where to put things
config_opts+=(
    -Dprefix="${PREFIX}"
    -Dsiteprefix="${PREFIX}"
    -Dvendorprefix="${PREFIX}"
    )

# This version of `./Configure` seems insistent on dropping "perl5" from the
# libraries paths (e.g., `lib/$version` instead of `lib/perl5/$version`), so we
# need to take "corrective action".
perl_arch="${HOST_ARCH}-${HOST_OS}-thread"
config_opts+=(
    -Dprivlib="${PREFIX}/lib/perl5/${PKG_VERSION}"
    -Darchlib="${PREFIX}/lib/perl5/${PKG_VERSION}/${perl_arch}"
    -Dsitelib="${PREFIX}/lib/perl5/site_perl/${PKG_VERSION}"
    -Dsitearch="${PREFIX}/lib/perl5/site_perl/${PKG_VERSION}/${perl_arch}"
    -Dvendorlib="${PREFIX}/lib/perl5/vendor_perl/${PKG_VERSION}"
    -Dvendorarch="${PREFIX}/lib/perl5/vendor_perl/${PKG_VERSION}/${perl_arch}"
    )

# To better match the Filesystem Hierarchy Standard, move manpages out of
# "${PREFIX}/man" and into "${PREFIX}/share/man", 
config_opts+=(
    -Dman1dir="${PREFIX}/share/man/man1"
    -Dman3dir="${PREFIX}/share/man/man3"
    -Dsiteman1dir="${PREFIX}/share/man/man1"
    -Dsiteman3dir="${PREFIX}/share/man/man3"
    -Dvendorman1dir="${PREFIX}/share/man/man1"
    -Dvendorman3dir="${PREFIX}/share/man/man3"
    )

# Tweak manpage extensions; in particular, use Debian's "3perl" convention to
# clearly identify documentation for Perl functions/library calls.
config_opts+=(
    -Dman1ext="1"
    -Dman3ext="3perl"
    )

# Build Perl using the Anaconda toolchain and our toolchain flags.
#
# NOTE: Using "${CC}" rather than "${LD}" for our linker (`-Dld`) to avoid `ld`
# "unrecognized option" errors when building standard Perl modules. (Removing
# the `-Wl,` parts from "${LDFLAGS}" is _not_ an option, as doing that causes
# "${CC}" to fail with "unrecognized command line option" errors.)
config_opts+=(
    -Dcpp="${CPP}"
    -Dcc="${CC}"
    -Dld="${CC}"
    -Dccflags="${CFLAGS}"
    -Dcccdlflags="-fPIC"
    -Dldflags="${LDFLAGS}"
    -Dlddlflags="${LDDLFLAGS} ${LDFLAGS}"
    -Dlocincpth="${PREFIX}/include"
    -Dloclibpth="${PREFIX}/lib"
    )

# Need to set `sysroot` option so `Configure` and `make` steps know how to find
# headers and libraries for this "non-standard" toolchain. Without it, we get
# errors like being unable to find "errno.h".
if [[ -n "${CONDA_BUILD_SYSROOT}" ]]; then
    config_opts+=(-Dsysroot="${CONDA_BUILD_SYSROOT}")
fi

# Enable support for threads
config_opts+=(-Dusethreads)

# Enable support for files > 2-GiB. (Should be "on" by default since our only
# targets are modern, 64-bit platforms, but just in case...)
config_opts+=(-Duselargefiles)

# Enable support for 64-bit scalar values (ints) and 64-bit pointers. (Again,
# should be "on" by default for our target platforms, but just in case...)
config_opts+=(-Duse64bitall)

# Use long doubles to enhance the range and precision of double-precision
# floating point numbers
config_opts+=(-Duselongdouble)

# Do NOT use GCC's `quadmath` library, even if it's available.
config_opts+=(-Uquadmath)

# Disable SOCKS proxy support, mostly because it triggers undefined symbol
# errors, and this currently does not seem like an important enough feature to
# spend the time figuring out what's going wrong.
config_opts+=(-Uusesocks)

# Make sure `perl` uses dynamic loading; a must have so we can build extension
# (XS) modules without having to recompile Perl itself.
config_opts+=(-Dusedl)

# The "-Duserelocatableinc" option builds a "relocatable Perl tree", which is
# the magic needed to install Perl inside conda environments. This option is
# incompatible with building a shared Perl library (i.e., the "-Duseshrplib"
# and "-Dlibperl="libperl.so.<ver>" options); see the INSTALL file for details.
config_opts+=(-Duserelocatableinc)
config_opts+=(-Uuseshrplib)

# Improve interpreter security removing '.' as the last element of `@INC`;
# default behavior as of Perl 5.26.0.
#
# NOTE: We _may_ revisit this decision and undefine this option (i.e., change
# `-D` to `-U) if we find too many the modules and/or scripts in BioBuilds are
# having trouble coping with this new behavior. (Though the preferred option
# would be to have the upstream maintainers fix this now-broken behavior.)
config_opts+=(-Ddefault_inc_excludes_dot)

# Turn off run-time customization of `@INC`. Enabling this seems contrary to
# the ability to reliably reproduce conda environments.
config_opts+=(-Uusesitecustomize)

# Do not build a debugging version of the Perl interpreter
config_opts+=(-UDEBUGGING)

# Generic optimization flag(s) to pass to the compiler; mostly, we're using
# this to exclude the `-g` flag (build in debugging information).
config_opts+=(-Doptimize="-O3")

# Install _all_ parts of Perl, and not just the version-specific bits. (The
# `-Dversiononly` option is one way to install multiple versions of Perl
# alongside each other, but that's not really something you should be doing
# with conda environments.)
config_opts+=(-Uversiononly)

# Make sure we don't accidentally enable AFS (Andrew File System) support
config_opts+=(-Uafs)

# Assume the C shell (`csh`) does not exist in this universe; helps avoid
# potential globbing misbehaviors when deploying on different systems.
config_opts+=(-Ud_csh)

# `Time::HiRes ualarm` may be buggy and/or non-functional on certain systems;
# if our users reporting such issues, uncomment this configuration option.
# See: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=448965
#config_opts+=(-Uualarm)

# Do not use the SFIO library, even if it's present on the build server;
# prevents the accidental introduction of a runtime dependency.
config_opts+=(-Uusesfio)

# Platform-specific config options
case "${HOST_OS}" in
    "linux")
        # Make sure `./Configure` does not accidentally introduce runtime
        # dependencies on various BSD utility libraries
        config_opts+=(-Ui_libutil)
        config_opts+=(-Ui_xlocale)
        ;;
    "darwin")
        # None at this time
        ;;
esac

# Use our zlib package when building the `Compress-Raw-Zlib` module, rather
# than building it from the sources packaged along with Perl.
export BUILD_ZLIB=False
export ZLIB_INCLUDE="${PREFIX}/include"
export ZLIB_LIB="${PREFIX}/lib"

# Similar story for building `Compress-Raw-Bzip2`
export BUILD_BZIP2=0
export BZIP2_INCLUDE="${PREFIX}/include"
export BZIP2_LIB="${PREFIX}/lib"


##  Now we're ready to run the build process...
./Configure -d -e -s \
    "${config_opts[@]}" \
    2>&1 | tee configure.log

make -j${MAKE_JOBS} \
    2>&1 | tee build.log

# The vast, vast majority of tests pass, but some tend to (or will) fail due to
# factors like sensitivity to server load/configuration or requiring
# permissions not available to processes running in containers. So for now,
# skip the `make test` step.
#make -j${MAKE_JOBS} test 2>&1

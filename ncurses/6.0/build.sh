#!/bin/bash
set -x -u

# Use the C++11 standard, rather than C++98/GNU++98 (default for g++ 4.8.x
# that's our default compiler for POWER8 packages). Otherwise, C++ compilation
# may fail with errors arising from the THROWS and THROW2 macros.
export CXXFLAGS="-std=c++11 ${CXXFLAGS:-}"

## Generate a list of options for `./configure`
declare -a config_opts

# Enable support for wide characters (UTF-8) because this is 2019, and we have
# users whose default language goes beyond 8-bit ASCII (i.e., not US English).
config_opts+=(--enable-widec)

# What to build
config_opts+=(--without-libtool)    # do NOT use libtool to build libraries
config_opts+=(--with-normal)        # i.e., static libraries
config_opts+=(--with-shared)
config_opts+=(--with-cxx-shared)
config_opts+=(--with-progs)         # utility programs like `tic`
config_opts+=(--without-manpages)

# Separate terminal information and functions used only by the utility
# applications into their own libraries (termlib and ticlib, respectively).
config_opts+=(--with-termlib)
config_opts+=(--with-ticlib)
#config_opts+=(--disable-tic-depends)

# Set types for various data structures for better compatibility with 64-bit
# executables; refer to the ncurses `INSTALL` document for details.
config_opts+=(--disable-lp64)
config_opts+=(--with-chtype='long')
config_opts+=(--with-mmask-t='long')

# Make sure all platforms agree that `char` is signed
config_opts+=(--enable-signed-char)

# May need these options if conda has trouble performing its relocation magic
#config_opts+=(--enable-rpath)
#config_opts+=(--disable-relink)

# May need this option if we start seeing symbol collisions
#config_opts+=(--with-versioned-syms)

# Build ncurses in "pure terminfo" mode, and disable support for falling back
# to termcap to get terminal information. Doing so makes the resulting ncurses
# libraries lighter and is required for using the `--with-ticlib` option.
#
# ** NOTE **: the "ncurses" package in the "defaults" channel is built using
# `--enable-termcap`, and this _may_ have compatibility implications.
config_opts+=(--enable-database)        # "database" => terminfo
config_opts+=(--disable-termcap)
config_opts+=(--disable-getcap)
config_opts+=(--disable-getcap-cache)

# Tell the ncurses library where to find terminal information
config_opts+=(--with-default-terminfo-dir="${PREFIX}/share/terminfo")
config_opts+=(--with-terminfo-dirs="${PREFIX}/etc/terminfo:${PREFIX}/lib/terminfo:${PREFIX}/share/terminfo")
config_opts+=(--disable-home-terminfo)

# Tell `tic` to save space by using symbolic links, rather than hard links,
# when writing aliases in the terminfo database.
config_opts+=(--enable-symlinks)

# Additional language bindings
config_opts+=(--without-ada)
config_opts+=(--with-cxx-binding)
config_opts+=(--with-cxx)               # adjust ncurses `bool` to match C++

# Support Anaconda's `pkg-config` for configuring builds that use ncurses
config_opts+=(--enable-pc-files)
config_opts+=(--with-pkg-config-libdir="${PREFIX}/lib/pkgconfig")

# Install ncurses headers in their own subdirectory of "${PREFIX}/include" and
# omit linking to `-lcurses`; helps avoid potential confusion and/or breaks if
# more than one version of ncurses is installed on the user's system.
config_opts+=(--disable-overwrite)

# Disable mouse support
config_opts+=(--without-gpm)
config_opts+=(--without-sysmouse)
config_opts+=(--disable-ext-mouse)

# Disable support for developing ncurses itself
config_opts+=(--without-debug)
config_opts+=(--without-develop)
config_opts+=(--without-profile)
config_opts+=(--without-tests)

# Miscellaneous options
config_opts+=(--disable-root-environ)   # restrict environment when root
config_opts+=(--with-xterm-kbs=del)     # xterm backspace sends DEL
config_opts+=(--enable-echo)            # show build commands & warnings

# Extensions beyond the XSI specifications
config_opts+=(--enable-const)           # more effective use of ANSI C `const`
config_opts+=(--enable-ext-colors)      # 256-color support in terminals
config_opts+=(--enable-sp-funcs)        # SCREEN (pointer) extensions
config_opts+=(--enable-tcap-names)      # user-definable terminal capabilities


## Standard autotools-based build procedure
./configure \
    --prefix="${PREFIX}" \
    "${config_opts[@]}" \
    2>&1 | tee configure.log
make -j${CPU_COUNT} ${VERBOSE_AT} \
    2>&1 | tee build.log
make install

if [[ $(uname -s) == Linux ]]; then
    _SOEXT=.so
else
    _SOEXT=.dylib
fi

# Make the wide libraries appear as the non-wide libraries as well, effectively
# forcing wide character (UTF-8) support on all applications built using this
# version of the ncurses package.
#
# NOTE: Internationalization is definitely a Good Thing(TM), but this process
# is actually discouraged by the ncurses developers, as the wide and non-wide
# libraries have incompatible ABIs. However, both the "defaults" channel and
# previous BioBuilds releases have established this as precedent, so we'll
# continue to follow it in the interests of not breaking existing packages.
pushd ${PREFIX}/lib
for _LIB in form menu ncurses ncurses++ panel tic tinfo; do
    test -f lib${_LIB}w${_SOEXT} && \
        ln -sf lib${_LIB}w${_SOEXT} lib${_LIB}${_SOEXT}
    test -f lib${_LIB}w.a && ln -sf lib${_LIB}w.a lib${_LIB}.a

    pushd pkgconfig
    if [[ -f ${_LIB}w.pc ]]; then
        # Copying rather than symlinking so the `pkg-config` looks "correct",
        # at least as far as the includes directories are concerned.
        cp -fp ${_LIB}w.pc ${_LIB}.pc
        sed -i.bak 's:include/ncursesw:include/ncurses:g' ${_LIB}.pc
        sed -i.bak '/^Name:/{ s/w$//; }' ${_LIB}.pc
        sed -i.bak '/^Requires.private:/{ s/w,/,/g; s/w$//; }' ${_LIB}.pc

        # NOTE: NOT removing the 'w' suffix from the name of library to link
        # to; this will (hopefully) reduce the chances of the resulting
        # binaries breaking, should we ever decide to stop aliasing the wide
        # ncurses libraries as their non-wide counterparts.
        #sed -i.bak "s:-llib${_LIB}w:-lllib${_LIB}:g" ${_LIB}.pc

        rm -f ${_LIB}.pc.bak
    fi
    popd
done
popd

HEADERS_DIR_W="${PREFIX}/include/ncursesw"
HEADERS_DIR="${PREFIX}/include/ncurses"

mkdir -p "${HEADERS_DIR}"
for HEADER in $(ls $HEADERS_DIR_W); do
  ln -sf "${HEADERS_DIR_W}/${HEADER}" "${HEADERS_DIR}/${HEADER}"
done

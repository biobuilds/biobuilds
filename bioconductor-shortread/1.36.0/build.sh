#!/bin/bash

# 'Autobrew' is being used by more and more packages these days
# to grab static libraries from Homebrew bottles. These bottles
# are fetched via Homebrew's --force-bottle option which grabs
# a bottle for the build machine which may not be macOS 10.9.
# Also, we want to use conda packages (and shared libraries) for
# these 'system' dependencies. See:
# https://github.com/jeroen/autobrew/issues/3
export DISABLE_AUTOBREW=1

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

# For some reason, `./configure` doesn't correctly pick up all the R-supplied
# $LDFLAGS on ppc64le, so we need this to help it find libz.so ("-lz").
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

$R CMD INSTALL --build .

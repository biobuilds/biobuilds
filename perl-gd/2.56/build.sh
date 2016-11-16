#!/bin/bash

if [ `uname -s` == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

perl Build.PL
# Use "perl ./Build" instead of "./Build" to prevent "conda build" failures
# caused by "#!" lines > 255 chars triggering a "bad interpreter" error.
perl ./Build
perl ./Build test
perl ./Build install --installdirs site

# Remove obsolete scripts (i.e., the ones that the README tells us not to run)
cd "${PREFIX}"
rm -f bin/bdf2gdfont.PLS bin/cvtbdf.pl bin/README \
    share/man/man1/bdf2gdfont.PLS.1

#!/bin/bash

abort() {
    echo "FATAL: ${1:-unknown error}" >&2
    exit 1
}

[ -f "/src/bb-build-flags.env" ] || \
    abort "Could not find BioBuilds sources in /src"

# "--shell" option to drop into an interactive shell instead of immediately
# running "conda build"; this is particularly useful for recipe debugging.
shell=0
for arg in "$@"; do
    if [ "$arg" == "--shell" ]; then
        shell=1
        break
    fi
done

cd "/src"
source bb-build-flags.env ${BB_MAKE_JOBS:-1}

if [ $shell -eq 0 ]; then
    conda build $@
else
    exec /bin/bash -i
fi

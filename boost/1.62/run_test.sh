#!/bin/bash
set -o pipefail

HOST_OS=`uname -s`
ICU_LIB=icui18n

# Figure out which ICU version conda installed
if [[ "$HOST_OS" == "Darwin" ]]; then
    shared_ext="dylib"
    installed_icu_ver=$(readlink ${PREFIX}/lib/lib${ICU_LIB}.${shared_ext} | cut -d. -f2)
else
    shared_ext="so"
    installed_icu_ver=$(readlink ${PREFIX}/lib/lib${ICU_LIB}.${shared_ext} | cut -d. -f3)
fi
echo "INFO: installed ICU version = ${installed_icu_ver}" >&2

# Make sure our boost libraries link to the installed version
link_errors=0
for lib in graph locale log_setup regex; do
    if [[ "$HOST_OS" == "Darwin" ]]; then
        linked_icu_ver=$(otool -L ${PREFIX}/lib/libboost_${lib}.${shared_ext} | \
            grep lib${ICU_LIB} | awk '{print $1;}' | uniq | cut -d. -f2)
    else
        linked_icu_ver=$(ldd ${PREFIX}/lib/libboost_${lib}.${shared_ext} | \
            grep lib${ICU_LIB} | awk '{print $1;}' | uniq | cut -d. -f3)
    fi
    echo "DEBUG: libboost_${lib}.${shared_ext} linked to ICU ${linked_icu_ver}" >&2

    if [[ ${linked_icu_ver:-0} != $installed_icu_ver ]]; then
        echo "ERROR: libboost_${lib}.${shared_ext} linked to ICU ${linked_icu_ver}, but ICU ${installed_icu_ver} installed." >&2
        link_errors=$(( ${link_errors} + 1 ))
    fi
done
echo "INFO: number of link errors = ${link_errors}" >&2
[[ ${link_errors} -eq 0 ]] || exit 1

#!/bin/bash

if [ `uname -m` != 'ppc64le' ]; then
    echo "ERROR: veclib headers only available for POWER architectures" >&2
    exit 1
fi

# Set up the necessary subdirectories
INCLUDE_DIR="$PREFIX/include/veclib"
SHARE_SUFFIX="share/veclib-${PKG_VERSION}"
SHARE_DIR="${PREFIX}/${SHARE_SUFFIX}"
[ -d "${INCLUDE_DIR}" ] || mkdir -p "${INCLUDE_DIR}"
[ -d "${SHARE_DIR}" ] || mkdir -p "${SHARE_DIR}"

# Install the header files
cp -p include/*.h "${INCLUDE_DIR}"
echo "Version: veclib ${PKG_VERSION}" > "${INCLUDE_DIR}/VERSION.TXT"

# Install the license files
cp -p "license/ILAN_Z125-5589-05_CT600ML.pdf" "${SHARE_DIR}/LICENSE.pdf"
cat >LICENSE.TXT <<EOF
The veclib headers (Programs) are licensed under the following License
Information terms and conditions in addition to the Program license terms
previously agreed to by Client and IBM. If Client does not have previously
agreed to license terms in effect for the Program, the IBM International
License Agreement for Non-Warranted Programs (Z125-5589-05) applies.

A copy of the IBM International License Agreement for Non-Warranted Programs
is provided in the "\$PREFIX/${SHARE_SUFFIX}/LICENSE.pdf" file.
EOF

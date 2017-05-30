#!/bin/bash

# tar must be GNU tar so we can use its "--transform" argument
TAR=
for t in tar gtar; do
    TAR=`command -v $t`
    [ ! -z "$TAR" ] && { "$TAR" --version | head -n1 | grep -q 'GNU tar'; }
    if [[ $? -eq 0 ]]; then break; fi
done
if [[ "$TAR" == '' ]]; then
    echo "FATAL: could not find GNU tar in \$PATH" >&2
    exit 1
fi

set -e -x

ORIGIN="git@github.com:lab7/vcflib.git"
PKG_NAME="vcflib"
VERSION="1.0.0-rc1-16.05.18"
base_dir="${PWD}"

# Conda packages cannot have '-'s in their versions, so convert them to '_'s
pkg_tag="${PKG_NAME}-${VERSION//-/_}"
tar_path="${base_dir}/${PKG_NAME}_full-${VERSION//-/_}.tar"

[ -d "$PKG_NAME" ] || git clone "${ORIGIN}"
cd "$PKG_NAME"

git checkout -f "v${VERSION}"
git submodule update --recursive --init --checkout --force
git status -s | grep '^?? ' | cut -c4- | xargs rm -rfv

git archive --format tar --output "${tar_path}" \
    --prefix="${pkg_tag}/" HEAD

set -o pipefail
git submodule foreach --quiet --recursive \
    'for fn in $(git ls-files); do echo "${toplevel}/${path}/${fn}"; done' | \
    sed "s,${base_dir}/${PKG_NAME}/,," | \
    xargs "$TAR" --transform="s,^,${pkg_tag}/," --no-recursion -rf "${tar_path}"

bzip2 -f "${tar_path}"
sha1sum "${tar_path}.bz2"

#!/bin/bash
set -e -x

mydir=$(cd `dirname $BASH_SOURCE[0]` && pwd -P)
version=1.0.2
pkg_name="freebayes-${version}"
tar_path="${mydir}/freebayes-full-${version}.tar"

cd "$mydir"
[ -d freebayes ] || git clone "https://github.com/ekg/freebayes.git"
cd freebayes

git checkout -f "v${version}"
git submodule update --recursive --init
git status -s | grep '^?? ' | cut -c4- | xargs rm -rfv

git archive --format tar --output "${tar_path}" \
    --prefix="${pkg_name}/" HEAD

set -o pipefail
git submodule foreach --quiet --recursive \
    'for fn in $(git ls-files); do echo "${toplevel}/${path}/${fn}"; done' | \
    sed "s,${mydir}/freebayes/,," | \
    xargs tar --transform="s,^,${pkg_name}/," --no-recursion -rf "${tar_path}"

bzip2 -f "${tar_path}"
md5sum "${tar_path}.bz2"

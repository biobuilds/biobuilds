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
mydir=$(cd `dirname $BASH_SOURCE[0]` && pwd -P)
version=1.1.0
pkg_name="freebayes-${version}"
tar_path="${mydir}/freebayes_full-${version}.tar"

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
    xargs "$TAR" --transform="s,^,${pkg_name}/," --no-recursion -rf "${tar_path}"

bzip2 -f "${tar_path}"
sha1sum "${tar_path}.bz2"

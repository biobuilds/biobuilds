#!/bin/bash
set -e -x
set -o pipefail

mkdir -p "${PREFIX}/bin"
sed -i.bak "1s|^.*$|#!${PREFIX}/bin/perl|" parasight.pl
cp -fpv parasight.pl "${PREFIX}/bin"
chmod 755 "${PREFIX}/bin/parasight.pl"

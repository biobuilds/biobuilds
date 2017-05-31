#!/bin/bash
set -e -x -o pipefail

BIN_DIR="${PREFIX}/bin"
ETC_DIR="${PREFIX}/etc/${PKG_NAME}"
SHARE_DIR="${PREFIX}/share/${PKG_NAME}"
PERL5_DIR="${SHARE_DIR}/perl5"

mkdir -p "${BIN_DIR}" "${ETC_DIR}" "${PERL5_DIR}"
for script in bin/*; do
    fn=`basename $script`
    sed "
        s:@@PREFIX_BIN@@:${BIN_DIR}:g;
        s:@@PREFIX_ETC@@:${ETC_DIR}:g;
        s:@@PREFIX_PERL5@@:${PERL5_DIR}:g;
    " $script > "${BIN_DIR}/${fn}"
    chmod 755 "${BIN_DIR}/${fn}"
done
rm -f "${BIN_DIR}/snippy-make_tarball"

install -m 644 etc/snpeff.config "${ETC_DIR}"
install -m 644 perl5/* "${PERL5_DIR}"

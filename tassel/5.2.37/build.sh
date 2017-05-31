#!/bin/bash

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

# Patch paths in the launch scripts
for fn in run_pipeline.pl start_tassel.pl; do
    sed -i.0 "s:@@prefix@@:${PREFIX}:; s:@@sharedir@@:${SHARE_DIR}:;" "$fn"
    rm -f "${fn}.0"
done

# Make sure the target directories exist
mkdir -p "${PREFIX}/bin" "${SHARE_DIR}/lib"

# Install the launch scripts
mv run_pipeline.pl run_${PKG_NAME}_pipeline.pl
install -m 0755 run_${PKG_NAME}_pipeline.pl start_tassel.pl "${PREFIX}/bin"

# Install the JAR files
install -m 0644 *.jar "${SHARE_DIR}"
install -m 0644 lib/* "${SHARE_DIR}/lib"

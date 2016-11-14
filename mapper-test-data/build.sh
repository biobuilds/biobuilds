#!/bin/bash

DEST="${PREFIX}/share/${PKG_NAME}"

cd example
for d in reads reference; do
    install -m 0755 -d "${DEST}/${d}"
    install -m 0644 ${d}/* "${DEST}/${d}"
done

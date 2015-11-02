#!/bin/bash

TARGET="${PREFIX}/share/autoconf"
[ -d "$TARGET" ] || mkdir -p "$TARGET"
cp -f "${RECIPE_DIR}/config.guess" "${TARGET}/config.guess"
cp -f "${RECIPE_DIR}/config.sub" "${TARGET}/config.sub"

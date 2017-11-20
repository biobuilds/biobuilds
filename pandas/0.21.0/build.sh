#!/bin/bash

# -fno-strict-aliasing is likely essential on clang, and silences lots of warnings on linux
# -fwrapv because that's what Pandas do on their CI:
# https://github.com/pandas-dev/pandas/pull/12946
CFLAGS="${CFLAGS} -fno-strict-aliasing -fwrapv" \
    python setup.py install --single-version-externally-managed --record=record.txt

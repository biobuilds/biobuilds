#!/bin/bash

env LDFLAGS="$LDFLAGS -Wl,-rpath,${PREFIX}/lib" \
    ./bootstrap --prefix="${PREFIX}" \
        --parallel=${CPU_COUNT} \
        --no-qt-gui \
        --system-curl \
        --system-expat \
        --system-zlib \
        --system-bzip2 \
        --system-liblzma \
        -- \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DCMAKE_FIND_ROOT_PATH="${PREFIX}"
make -j${CPU_COUNT}
make install

#!/bin/bash

./configure --prefix="$PREFIX" \
            --enable-shared=yes \
            --enable-static=yes
make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

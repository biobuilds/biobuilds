#!/bin/bash

./configure --prefix=${PREFIX}
make -j${CPU_COUNT} ${VERBOSE_AT}
make -j 1 check && make install

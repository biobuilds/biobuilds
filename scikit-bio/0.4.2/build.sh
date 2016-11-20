#!/bin/bash

env CFLAGS="${CFLAGS} -I${PREFIX}/include" \
    $PYTHON setup.py install

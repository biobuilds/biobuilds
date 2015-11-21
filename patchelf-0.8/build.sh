#!/bin/bash

./configure --prefix="${PREFIX}"
make
make install
rm -rf "${PREFIX}/share"

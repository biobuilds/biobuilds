#!/bin/bash

set -o pipefail
[ "$BB_MAKE_JOBS" == "<UNDEFINED>" ]  && BB_MAKE_JOBS=1

./configure --prefix="$PREFIX" 2>&1 | tee configure.log
make -j${BB_MAKE_JOBS}
make install

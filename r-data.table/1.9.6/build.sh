#!/bin/bash

$R CMD INSTALL --build .

# Build script moves "data.table.so" to "datatable.so" so we need to change the
# name of the shared library, or the conda post-build (RPATH-munging) process
# will get confused (trying to find "data.table.so" instead of "datatable.so").
if [ `uname -s` == 'Darwin' ]; then
    install_name_tool -id datatable.so \
        "${PREFIX}/lib/R/library/data.table/libs/datatable.so"
fi

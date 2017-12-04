#!/bin/bash

# `picard -h` exits with a non-zero code, so prevent bash from exiting
# immediately on a command failure, or our tests will never pass.
set +e
picard -h &>picard-help.out
set -e

# Make sure some of our favorite programs exist
egrep '\<(SortSam|SortVcf)\>' picard-help.out

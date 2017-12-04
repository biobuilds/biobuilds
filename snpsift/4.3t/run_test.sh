#!/bin/bash

# `snpSift -h` exits with a non-zero code, so prevent bash from exiting
# immediately on a command failure, or our tests will never pass.
set +e
snpSift --help &>snpsift-help.out
set -e

# Make sure some of our favorite programs exist
egrep '^Usage: java -jar SnpSift.jar ' snpsift-help.out

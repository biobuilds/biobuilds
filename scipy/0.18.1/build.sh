#!/bin/bash

if [ `uname -m` != 'ppc64le' ]; then
    echo "ERROR: This package can only be built for the 'linux-ppc64le' platform!" >&2
    echo "ERROR: All other platforms should use the 'defaults' channel package." >&2
    exit 1
fi

$PYTHON setup.py install

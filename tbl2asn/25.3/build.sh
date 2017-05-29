#!/bin/bash

./make/makedis.csh

mkdir -p "${PREFIX}/bin"
install -m 0755 bin/tbl2asn "${PREFIX}/bin"

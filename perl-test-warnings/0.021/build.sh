#!/bin/bash

perl Makefile.PL INSTALLDIRS=site
make
make test
make install
rm -rf "${PREFIX}/man"  "${PREFIX}/share/man"

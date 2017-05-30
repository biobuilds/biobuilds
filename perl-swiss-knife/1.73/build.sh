#!/bin/bash

# Using Makefile.PL approach per the instructions in the package's README.
# (Also, the "perl Build.PL" approach leads to failed tests.)
perl Makefile.PL INSTALLDIRS=site
make
make test
make install

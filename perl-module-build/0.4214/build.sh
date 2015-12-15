#!/bin/bash

perl Build.PL
./Build
./Build test
./Build install --installdirs site

#perl Makefile.PL INSTALLDIRS=site
#make
#make test
#make install

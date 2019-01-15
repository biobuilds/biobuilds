#!/bin/bash

cd "XS-Tutorial"
perl Makefile.PL
make
make install
perl -MXS::Tutorial::One -E '
    XS::Tutorial::One::srand(777);
    print XS::Tutorial::One::rand(), "\n";
    '

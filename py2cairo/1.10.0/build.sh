#!/bin/bash

./waf configure --prefix=$PREFIX
./waf build
./waf install

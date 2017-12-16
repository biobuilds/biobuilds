#!/bin/bash

set -e -o pipefail

unzip -h
unzipsfx -h
#zipgrep -h
zipinfo -h

funzip testmake.zip
unzip -t testmake.zip
zipgrep notes testmake.zip
zipinfo testmake.zip

# Creation of self-extracting archives currently does not work
cat "${PREFIX}/bin/unzipsfx" testmake.zip > testmake
zip -A testmake
chmod 755 testmake
./testmake -t

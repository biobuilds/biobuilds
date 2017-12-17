#!/bin/bash

unix2dos -n README.txt README.txt.dos
unix2mac -n README.txt README.txt.mac
dos2unix -n README.txt.dos README.txt.unx

md5sum -c - <<EOF
b172ca5a5e9d2fd9a7ef5b6d3906f877  README.txt
80c917fdec82f7ce4fee1745f2eff01f  README.txt.dos
c60c5a1a0bd70d355e3c2ec63f7f23a1  README.txt.mac
b172ca5a5e9d2fd9a7ef5b6d3906f877  README.txt.unx
EOF

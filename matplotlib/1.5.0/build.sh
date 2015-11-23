#!/bin/bash

cp -f setup.cfg.template setup.cfg || exit 1
sed -i.orig "s:/usr/local:$PREFIX:g" setupext.py
$PYTHON setup.py install

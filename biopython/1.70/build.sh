#!/bin/bash

"$PYTHON" setup.py build
"$PYTHON" setup.py test
"$PYTHON" setup.py install

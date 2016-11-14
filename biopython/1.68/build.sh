#!/bin/bash

# "test" seems to be hanging on "test_NCBI_qblast" in our x86_64 build VMs;
# however, the build seems to be ok, so we'll skip internal tests for now.
#"$PYTHON" setup.py build
#"$PYTHON" setup.py test

"$PYTHON" setup.py install

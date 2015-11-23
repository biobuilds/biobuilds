#!/bin/bash

# Not much to do build-wise except squash the auto-generated conda build
# strings (relating to the Python, Numpy, and R releases). Since a given
# BioBuilds release fixes (pins) these, there's little reason to attach
# such a long build string to the release package.
echo "0" > __conda_buildstr__.txt

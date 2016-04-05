#!/bin/bash

gunzip test.fq.gz
fastqc test.fq

# Verify output files exist and are non-empty
[ -f test_fastqc.html ] && [ -s test_fastqc.html ]
[ -f test_fastqc.zip ]  && [ -s test_fastqc.zip ]

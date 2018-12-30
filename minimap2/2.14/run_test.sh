#!/bin/bash

minimap2 --help

## Example commands from the README

# long sequences against a reference genome
minimap2 -a test/MT-human.fa test/MT-orang.fa > test.sam

# create an index first and then map
minimap2 -d MT-human.mmi test/MT-human.fa
minimap2 -a MT-human.mmi test/MT-orang.fa > test.sam

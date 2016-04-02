#!/bin/bash

mb <<EOF
execute primates.nex
set Npthreads = 2
lset nst=6 rates=invgamma
mcmc ngen=5000 samplefreq=10
yes
sump burnin=250
sumt burnin=250
quit
EOF

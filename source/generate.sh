#!/bin/bash

if [[ $1 -eq 0 ]] 
then
    echo "Enter number of samples"
    exit 1
fi
    ./fm_radio test/usrp.dat
    head -c $(($1*4)) test/usrp.dat > sim/din.dat
    head -c $(($1/8*4)) test/usrp.out > sim/cmp.dat
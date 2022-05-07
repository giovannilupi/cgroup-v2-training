#!/bin/bash

MAX_PROCS=20
I=1

while [ $I -le $MAX_PROCS ] ; do
    sleep 60 &
    echo "[$I]" $!
    I=$((I+1))
done
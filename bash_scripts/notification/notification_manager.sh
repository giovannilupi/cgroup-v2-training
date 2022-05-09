#!/bin/bash

CGDIR=/sys/fs/cgroup

# create a new cgroup
mkdir $CGDIR/newcgrp
echo "[Manager] New cgroup created"

# run listener program in background
./listener.sh &

sleep 1
I=0
# add 3 sleep processes to the cgroup
while [ $I -lt 3 ]; do
    I=$((I+1))
    sleep 8 &
    SPID=$!
    echo $SPID >> $CGDIR/newcgrp/cgroup.procs
    echo "[Manager] New sleep process added to the cgroup : $SPID"
    sleep 1
done

# poll cgroup.events file until the group is empty
while grep "populated 1" $CGDIR/newcgrp/cgroup.events > /dev/null 2>&1; do
        sleep 1
done

echo "[Manager] cgroup empty"

# clean up
rmdir $CGDIR/newcgrp
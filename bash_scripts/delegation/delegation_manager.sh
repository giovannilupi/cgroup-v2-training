#!/bin/bash

CGDIR=/sys/fs/cgroup
CPU=0
USR=$1
UPID=$2

echo ""
echo "--- DELEGATION MANAGER ---"
echo ""

# block intended for hierarchy clean up
if [ $USR = "cleanup" ]; then
    for P in `cat $CGDIR/delegcgrp/cgroup.procs`; do 
        echo $P >> $CGDIR/cgroup.procs 2>/dev/null
    done
    for P in `cat $CGDIR/delegcgrp/a/cgroup.procs`; do 
        echo $P >> $CGDIR/cgroup.procs 2>/dev/null
    done
    for P in `cat $CGDIR/delegcgrp/b/cgroup.procs`; do 
        echo $P >> $CGDIR/cgroup.procs 2>/dev/null
    done
    rmdir $CGDIR/delegcgrp/{a,b}
    if rmdir $CGDIR/delegcgrp ; then 
        echo "Cleanup successful"
    fi
    exit
fi

# create a new cgroup
mkdir $CGDIR/delegcgrp
# delegate the new cgroup to the unprivileged user
chown $USR:$USR $CGDIR/delegcgrp

# change ownership of the mandatory files for delegation
cat /sys/kernel/cgroup/delegate | while read line ; do
    echo "Changing ownership of $line"
    chown $USR:$USR $CGDIR/delegcgrp/$line
done

sleep 4

echo ""
echo "Moving user process into the root of the delegated subtree"
echo $UPID > $CGDIR/delegcgrp/cgroup.procs
sleep 5
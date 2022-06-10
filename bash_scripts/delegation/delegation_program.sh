#!/bin/bash

CGDIR=/sys/fs/cgroup

echo "PID of delegation_program is: $$"

sudo ./delegation_manager.sh $USER $$

echo ""
echo "--- DELEGATION PROGRAM ---"
echo ""

# create two new cgroups
mkdir $CGDIR/delegcgrp/{a,b}

echo "Creating sleep process..."
sleep 100 &
SPID=$!
echo "PID of the sleep process is: $SPID"
sleep 5

echo "PIDs inside the root of the delegated subtree:"
cat $CGDIR/delegcgrp/cgroup.procs
echo ""
sleep 6

echo "Moving sleep process (PID $SPID) to subgroup a"
echo $SPID > $CGDIR/delegcgrp/a/cgroup.procs
echo ""
sleep 2

echo "PIDs inside subgroup a:"
cat $CGDIR/delegcgrp/a/cgroup.procs
echo ""
sleep 5

echo "Moving sleep process (PID $SPID) from subgroup a to subgroup b"
echo $SPID > $CGDIR/delegcgrp/b/cgroup.procs
echo ""
sleep 2

echo "PIDs inside subgroup a:"
cat $CGDIR/delegcgrp/a/cgroup.procs
echo "PIDs inside subgroup b:"
cat $CGDIR/delegcgrp/b/cgroup.procs
echo ""
sleep 5

echo "Trying to move sleep process (PID $SPID) outside the delegated subtree"
echo "This operation will be unseccessfull because it violates the containment rules"
echo $SPID > $CGDIR/cgroup.procs
sleep 5

sudo ./delegation_manager.sh cleanup
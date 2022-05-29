#!/bin/bash

CGDIR=/sys/fs/cgroup
BINFOLDER=../../bin
CPU=0

echo "Creating a new sub-hierarchy..."
mkdir $CGDIR/thr
mkdir $CGDIR/thr/a
mkdir $CGDIR/thr/a/b
mkdir $CGDIR/thr/a/c
mkdir $CGDIR/thr/a/c/d
sleep 2

echo ""
echo "The current status of the newly created sub-hierarchy is:"
echo ""
$BINFOLDER/treeprt $CGDIR/thr
echo ""
sleep 7

echo "Let's make the subtree threaded"
echo "threaded" > $CGDIR/thr/a/cgroup.type
echo "After converting the type of cgroup a to threaded, the tree is in the current status: "
echo ""
$BINFOLDER/treeprt $CGDIR/thr
echo ""
sleep 7

echo "To make the threaded tree usable, domain invalid cgroups must be converted to threaded"
echo "threaded" > $CGDIR/thr/a/b/cgroup.type
echo "threaded" > $CGDIR/thr/a/c/cgroup.type
echo "threaded" > $CGDIR/thr/a/c/d/cgroup.type
echo "Now the tree status is:"
$BINFOLDER/treeprt $CGDIR/thr
echo ""
sleep 7

echo "Let's run a multi-threaded cpu burning program and observe its behavior in a new terminal window"
$BINFOLDER/thread_example 3 &
BPID=$!
sleep 10

echo ""
echo "We can try to move the PID of the multi-threaded process in the cgroup.procs file of the threaded cgroup c"
echo $BPID > $CGDIR/thr/a/c/cgroup.procs
sleep 2
$BINFOLDER/treeprt $CGDIR/thr
echo ""
echo "The process has been moved to the threaded root"
sleep 7

echo ""
echo "Let's activate the cpu controller along the hierarchy..."
if grep cpu $CGDIR/cgroup.subtree_control > /dev/null 2>&1; then
    echo "cpu already in the root subtree_control"
else
    # enable the cpu controller in the children cgroups of the root
    echo "+cpu" > $CGDIR/cgroup.subtree_control
    CPU=1
    echo "Added cpu to the root subtree_control"
fi
echo "+cpu" > $CGDIR/thr/cgroup.subtree_control
echo "+cpu" > $CGDIR/thr/a/cgroup.subtree_control
echo "+cpu" > $CGDIR/thr/a/b/cgroup.subtree_control
echo "+cpu" > $CGDIR/thr/a/c/cgroup.subtree_control
sleep 1
echo "... and set the cpu limit to 30% using a threaded controller"
echo '30000 100000' > $CGDIR/thr/a/c/cpu.max
sleep 18

# clean up
kill $BPID
sleep 2
rmdir $CGDIR/thr/a/c/d
rmdir $CGDIR/thr/a/b
rmdir $CGDIR/thr/a/c
rmdir $CGDIR/thr/a
rmdir $CGDIR/thr

if [ $CPU = "1" ]; then
    echo "-cpu" > $CGDIR/cgroup.subtree_control
    echo "Remove cpu from subtree_control"
fi

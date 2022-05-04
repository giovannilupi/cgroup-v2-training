#!/bin/bash

CGDIR=/sys/fs/cgroup
CPU=0

function show_cpu() {
    top -d 1 -n 10 | grep burner_program
}

if grep cpu $CGDIR/cgroup.subtree_control > /dev/null 2>&1; then
    echo "cpu already in subtree_control"
else
    # enable the cpu controller in the children cgroups of the root
    echo "+cpu" > $CGDIR/cgroup.subtree_control
    CPU=1
    echo "Added cpu to subtree_control"
fi

# create a new cgroup
mkdir $CGDIR/burner
# set the cgroup maximum bandwidth limit
# this cgroup can only consume a maximum of 20% of the cpu resources
echo '20000 100000' > $CGDIR/burner/cpu.max

./burner_program.sh &
BPID=$!
echo "Burner program running at full power"
echo ""
show_cpu
echo "Setting CPU limit for burner program"
echo $BPID > $CGDIR/burner/cgroup.procs
echo ""
echo "CPU limit successfully set for burner program"
echo ""
show_cpu
# clean up
kill $BPID
sleep 2
rmdir $CGDIR/burner
if [ $CPU = "1" ]; then
    echo "-cpu" > $CGDIR/cgroup.subtree_control
    echo "Remove cpu from subtree_control"
fi
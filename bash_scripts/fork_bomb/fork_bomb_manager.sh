#!/bin/bash

CGDIR=/sys/fs/cgroup
PIDS=0

if grep pids $CGDIR/cgroup.subtree_control > /dev/null 2>&1; then
    echo "pids already in subtree_control"
else
    # enable the pids controller in the children cgroups of the root
    echo "+pids" > $CGDIR/cgroup.subtree_control
    PIDS=1
    echo "Added pids to subtree_control"
fi

# create a new cgroup
mkdir $CGDIR/forkbomb
# insert the current shell in the cgroup
echo $BASHPID > $CGDIR/forkbomb/cgroup.procs
# N is equal to the number of processes already present in the cgroup + 10
N=`cat $CGDIR/forkbomb/pids.current`
N=$((N+10))
# the number of processes that can be contained in the cgroup is limited to N
# hence, only 10 more processes can be added to the cgroup
echo $N > $CGDIR/forkbomb/pids.max
echo ""
echo "The maximum number of processes in the cgroup was set to:"
cat $CGDIR/forkbomb/pids.max
echo ""
echo "Number of new processes limited to 10"
echo ""
echo "Starting bomb program..."
./bomb_program.sh

echo ""
echo "Sleeping for 2 seconds"
sleep 2
echo "End sleep"
echo ""

# clean up
echo "Migrating all forkbomb processes to root cgroup"
for P in `cat $CGDIR/forkbomb/cgroup.procs`; do 
    echo $P >> $CGDIR/cgroup.procs 2>/dev/null
done
# all the processes of the cgroup have been move outside, so the folder can now be deleted
rmdir $CGDIR/forkbomb
echo "cgroup deleted successfully"
if [ $PIDS = "1" ]; then
    echo "-pids" > $CGDIR/cgroup.subtree_control
    echo "Remove pids from subtree_control"
fi
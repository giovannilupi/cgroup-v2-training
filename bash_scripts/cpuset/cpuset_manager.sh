#!/bin/bash

CGDIR=/sys/fs/cgroup
CPUSET=0
CPU=0

echo "The current system has the following amount of CPUs available:"
lscpu | grep -m2 "CPU(s)"
sleep 3

echo ""
echo "Let's observe the CPUs status with htop in a new terminal..."
echo ""
sleep 8

echo "Let's now run a cpu-intensive program to observe the status change"
echo ""
./burner_program.sh &
BPID=$!
sleep 20

echo "Let's create a new cgroup and activate the cpuset controller"
echo ""

if grep cpuset $CGDIR/cgroup.subtree_control > /dev/null 2>&1; then
    echo "cpuset already in subtree_control"
else
    # enable the cpu controller in the children cgroups of the root
    echo "+cpuset" > $CGDIR/cgroup.subtree_control
    CPUSET=1
    echo "Added cpuset to subtree_control"
fi

mkdir $CGDIR/csgroup
echo "The CPUs allowed to be used by the tasks in the cgroup are listed in the cpuset.cpus.effective file:"
cat $CGDIR/csgroup/cpuset.cpus.effective
sleep 5
echo ""
echo "We can request to use only CPU 2 by writing the number into the cpuset.cpus file..."
echo 2 > $CGDIR/csgroup/cpuset.cpus
echo "The content of the cpuset.cpus.effective file is now:"
cat $CGDIR/csgroup/cpuset.cpus.effective
sleep 5

echo ""
echo "Now let's move the burner process to the new cgroup and observe the status change"
echo $BPID > $CGDIR/csgroup/cgroup.procs
sleep 15

echo ""
echo "As an experiment, let's create the child cgroups a and b and migrate the burner process to a"
mkdir $CGDIR/csgroup/{a,b}
echo $BPID > $CGDIR/csgroup/a/cgroup.procs
echo "+cpuset" > $CGDIR/csgroup/cgroup.subtree_control
echo 2 > $CGDIR/csgroup/a/cpuset.cpus
echo ""
echo "Burner process sucessfully moved to cgroup a. Content of the cgroup.procs file:"
cat $CGDIR/csgroup/a/cgroup.procs
sleep 5

echo ""
echo "Let's activate the cpu controlller as well to limit CPU 2 consumption to 25%"
if grep "cpu\b" $CGDIR/cgroup.subtree_control > /dev/null 2>&1; then
    echo "cpu already in subtree_control"
else
    # enable the cpu controller in the children cgroups of the root
    echo "+cpu" > $CGDIR/cgroup.subtree_control
    CPU=1
    echo "Added cpu to subtree_control"
fi
#echo "+cpu" > $CGDIR/cgroup.subtree_control
echo "+cpu" > $CGDIR/csgroup/cgroup.subtree_control
echo '25000 100000' > $CGDIR/csgroup/a/cpu.max
sleep 15

echo ""
echo "Let's set the same cpuset and cpu controls on the cgroup b"
echo 2 > $CGDIR/csgroup/b/cpuset.cpus
echo '25000 100000' > $CGDIR/csgroup/b/cpu.max
echo "Control interface files of cgroup b set successfully"
sleep 5

echo ""
echo "Let's now run another instance of burner program and assign it to cgroup b"
./burner_program.sh &
BPID2=$!
echo $BPID2 > $CGDIR/csgroup/b/cgroup.procs
echo "Now the two instances of the program belong to two different cgroups but share CPU 2"
sleep 15

# clean up
echo ""
echo "Cleaning up..."
kill $BPID
kill $BPID2
sleep 2
rmdir $CGDIR/csgroup/a
rmdir $CGDIR/csgroup/b
rmdir $CGDIR/csgroup

if [ $CPUSET = "1" ]; then
    echo "-cpuset" > $CGDIR/cgroup.subtree_control
    echo "Remove cpuset from subtree_control"
fi

if [ $CPU = "1" ]; then
    echo "-cpu" > $CGDIR/cgroup.subtree_control
    echo "Remove cpu from subtree_control"
fi

exit

function show_cpu() {
    top -d 1 -n 10 | grep burner_program
}

if grep "cpu\b" $CGDIR/cgroup.subtree_control > /dev/null 2>&1; then
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
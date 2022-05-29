# Threads example

Creating a threaded subtree, moving a multi-threaded process inside of it and limiting their cpu consumption.

## Description
The scripts inside this folder make use of two external C++ executables:
- `treeprt` : a program capable of printing a textual representation of a specified subtree of the cgroup hierarchy.
- `thread_example` : a program creating a specified number threads.

This folder contains two bash scripts:
- `threads_runner.sh` : this is the script to invoke to run the example. It must necessarily be executed from `tmux`. It first runs `top` in a new window with the -H option to show the behavior of the threads in the sytstem. It then launches `threads_manager.sh` as superuser.
- `threads_manager.sh` : this script first creates a new cgroup sub-hierarchy. It then changes the `cgroup.type` file inside one of the newly created folders to `threaded` in order to create a threaded subtree. The domain invalid cgroups are converted to threaded to make the subtree usable. Throughout the whole process, the sub-hierarchy status is displayed multiple times through the use of the `treeprt` program. Successively, it runs `thread_example` and observes the load of each thread on the cpu through the top command for a few seconds. After that, the PID of the process created by the invoked program is added to the `cgroup.procs` file of one of the cgroups in the hierarchy. The `cpu` controller is activated in the hierarchy and the `cpu.max` file is modified to limit the cpu consumption of each thread. The new behavior of the program is observed for a few seconds. After that, the process is killed and the cgroup hierarchy is restored to its previous state.

---

## Instructions

First, the <em>tmux</em> and <em>htop</em> packages must be installed with the following commands:
```
sudo apt install tmux
```
```
sudo apt install htop
```

The executables for `treeprt` and `thread_example` must be present in the bin folder. They can be compiled from source and automatically copied to the bin folder using make (for treeprt) and cmake (for thread_example.) 

The `threads_runner.sh` script must be run inside this folder using `tmux`.
First run `tmux`:
```
tmux
```
Inside tmux, run the script **without** root privileges:
```
./threads_runner.sh
``` 
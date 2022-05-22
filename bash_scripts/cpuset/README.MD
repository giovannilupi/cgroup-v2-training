# Cpuset example

Binding a cpu-intensive application to a specific CPU using the cpuset controller.

## Description
This folder contains three bash scripts:
- `burner_program.sh` : a script containing a simple loop, that mimics the behavior of a cpu intensive program.
- `cpuset_runner.sh` : this is the script to invoke to run the example. It must necessarily be executed from `tmux`. It first runs `htop` in a new window and then launches `cpuset_runner.sh` as superuser.
- `cpuset_runner.sh` : this script is the core of the example. It runs `burner_program.sh` to allow the user to observe the cpu status for a few second. After that, it adds the process to a new cgroup and binds it to the CPU number 2 using the cpuset controller. Later, it creates two new subfolders in the cgroup hierarchy, migrates the current burner program instance to one of them and activates the cpu controller to limit resource consumption. Lastly, it sets the brother cgroup control interface files with the same settings, runs another burner program instance and attaches it to that cgroup. This way, both instances will run and share resources form the same CPU. The script also performs a cleanup of the hiearchy.

---

## Instructions

First, the <em>tmux</em> and <em>htop</em> packages must be installed through the following commands:
```
sudo apt install tmux
```
```
sudo apt install htop
```

The `cpuset_runner.sh` script must be run inside this folder using `tmux` **without** root privileges:
```
sudo ./cpuset_runner.sh
``` 

**Note**: the terminal default color scheme may hide the cpu consumption percentages shown in htop. It is therefore advised to temporarily switch the terminal to a light theme to avoid the problem.
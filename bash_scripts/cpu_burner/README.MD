# CPU burner example

Limiting the cpu consumption of a cpu-intensive application.

## Description
This folder contains two bash scripts:
- `burner_program.sh` : a script containing a simple loop, that mimics the behavior of a cpu intensive program.
- `cpu_burner_manager.sh` : this script first creates a new cgroup and modifies its `cpu.max` file to limit the cpu consumption. It then runs `burner_program.sh` and observes its load on the cpu through the top command for 10 seconds. After that, the PID of the process created by the burner program is added to the `cgroup.procs` file of the newly created cgroup. The new behavior of the burner program is observed for 10 seconds. After that, the process is killed and the cgroup hierarchy is restored to its previous state.

---

## Instructions
The `cpu_burner_manager.sh` script must be run inside this folder with root privileges:
```
sudo ./cpu_burner_manager.sh
``` 

**Note**: the terminal window used to run the script must be wide enough to contain the output of the top program (120 columns is a reasonable choice), otherwise the "top | grep" command used to show CPU consumption will not work (because top will not display the names of the processes.)
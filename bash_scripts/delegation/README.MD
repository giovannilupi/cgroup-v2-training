# Delegation example

Delegating the management of a subhierarchy to an unprivileged user.

## Description
This folder contains two bash scripts:
- `delegation_manager.sh` : this script is invoked by `delegation_program.sh`. The first invocation receives two parameters: the PID of the caller process and the username of the delegatee. The script then creates a new cgroup and changes the ownership of the folder and all the files required for the delegation step. Lastly, it moves the PID of the previously mentioned caller process into the `cgroup.procs` file of the root of the delegated subtree. The script is called a second time with only one parameter in input to perform a clenaup of the hierarchy.
- `delegation_program.sh` : this script must be run by an unprivileged user. Once the script is running, it invokes `delegation_manager.sh` as superuser to be delegated a certain part of the hierarchy. Once the user has control of a subtree, it creates two subfolders in its root. It then runs a sleep proccess. Since the bash process running the script belongs to the root of the delegated subtree, the sleep process will be automatically placed there as well. The script successfully moves the PID of the sleep process to both the folders in its subtree. It then tries to move the sleep process outside of the delegated subtree. This operation fails, as it violates the containment rules. Lastly, `delegation_manager.sh` is invoked again to perform the cleanup.

---

## Instructions
The `delegation_program.sh` script must be run inside this folder **without** root privileges:
```
./delegation_program.sh
``` 

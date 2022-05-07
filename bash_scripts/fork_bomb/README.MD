# Fork bomb example

Constraining the number of processes in a cgroup.

## Description
This folder contains two bash scripts:
- `bomb_program.sh` : a script containing a simple loop that spawns 20 sleep processes.
- `fork_bomb_manager.sh` : this script creates a new cgroup, adds the current shell to it and subsequently modifies its `pids.max` file to limit the number of new process that can be added to the cgroup to 10. It then runs `bomb_program.sh` to show that no more than 10 new sleep processes can be spawned. Lastly, all the processes are migrated outside of the cgroup and the hierarchy is restored to its previous state.

---

## Instructions
The `fork_bomb_manager.sh` script must be run inside this folder with root privileges:
```
sudo ./fork_bomb_manager.sh
``` 
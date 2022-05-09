# Notification example

Obtain a notification when a cgroup becomes empty.

## Description
This folder contains two bash scripts:
- `listener.sh` : a script using inotify to monitor changes to the `cgroup.events` file of a cgroup. The script terminates when the `populated` key of the `cgroup.events` file becomes 0.
- `notification_manager.sh` : this script creates a new cgroup, runs the `listener.sh` script in background and then adds 3 sleep processes to the cgroup. When the cgroup becomes empty, the hierarchy is restored to its previous state.

---

## Instructions

First, the <em>inotify-tools</em> package must be installed through the following command:
```
sudo apt install inotify-tools
```

The `notification_manager.sh` script must be run inside this folder with root privileges:
```
sudo ./notification_manager.sh
``` 
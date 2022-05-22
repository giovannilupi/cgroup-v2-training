#!/bin/sh

if [ $TERM = "screen" ] ; then
    tmux split-window "htop"
    sudo ./cpuset_manager.sh
else
    echo "This script must be run inside tmux"
fi

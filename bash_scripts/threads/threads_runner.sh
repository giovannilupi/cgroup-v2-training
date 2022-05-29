#!/bin/sh

if [ $TERM = "screen" ] ; then
    tmux split-window "top -H"
    sudo ./threads_manager.sh
else
    echo "This script must be run inside tmux"
fi

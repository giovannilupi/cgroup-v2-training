#!/bin/bash

CGDIR=/sys/fs/cgroup

echo ""
echo "[Listener] Content of the cgroup.events file is: "
cat $CGDIR/newcgrp/cgroup.events
echo ""

# command line interface to the inotify subsystem
# listens for modify events on the cgroup.events file
while inotifywait -q -e modify $CGDIR/newcgrp/cgroup.events ; do
    echo "[Listener]" `grep populated $CGDIR/newcgrp/cgroup.events`
    # when the cgroup becomes empty, exit the loop
    if grep "populated 0" $CGDIR/newcgrp/cgroup.events > /dev/null 2>&1; then
        break
    fi
done

echo ""
echo "[Listener] terminated"
echo ""
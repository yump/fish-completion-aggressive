#!/usr/bin/env fish

set target_comm fish-3.5.1

# My terminal is configured to launch the shell in a new scope.
# If yours is not, use systemd-run.
set target_cg (awk -F ':' 'NR==1 {print $3}' /proc/(pgrep $target_comm)/cgroup)

echo "Do the thing that triggers the openat()s, then ^C"
#sudo perf record \
#    -a \
#    --event=syscalls:sys_enter_openat \
#    --cgroup $target_cg
#    --call-graph dwarf \
#    --output=perf.data.$target_comm

#alas, must chown manually

sudo bpftrace -e "
  tracepoint:syscalls:sys_enter_openat
  //hardware:cycles:1e6
  / cgroup == cgroupid(\"/sys/fs/cgroup/$target_cg\") /
  {
    @[ustack,pid,comm] = count();
  }
"


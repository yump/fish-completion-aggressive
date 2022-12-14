https://github.com/fish-shell/fish-shell/discussions/9217

Strace command:
    sudo strace -c -f -p 403091 # $fish_pid from the other terminal

# Without patch, "cd " pre-filled, press \<tab\>:

```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 79.94    0.037000        5285         7           poll
 10.13    0.004691           1      2554        21 newfstatat
  3.89    0.001802           3       516           openat
  3.87    0.001791           3       518           getdents64
  1.83    0.000845           1       520           close
  0.28    0.000131          16         8         1 futex
  0.02    0.000009           1         8         1 read
  0.02    0.000009           1         8           write
  0.01    0.000006           2         3           madvise
  0.00    0.000002           0        18           rt_sigprocmask
  0.00    0.000000           0        16        14 access
  0.00    0.000000           0         4           fcntl
  0.00    0.000000           0         6         6 readlink
  0.00    0.000000           0         1           restart_syscall
  0.00    0.000000           0         3           set_robust_list
  0.00    0.000000           0         1           pipe2
  0.00    0.000000           0         3           rseq
  0.00    0.000000           0         3           clone3
------ ----------- ----------- --------- --------- ----------------
100.00    0.046286          11      4197        43 total
```

# With patch, "cd " pre-filled, press \<tab\>:

```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 79.52    0.024528        4087         6           poll
  7.22    0.002226           4       518           getdents64
  6.48    0.001999           3       516           openat
  3.07    0.000948           1       554        21 newfstatat
  2.82    0.000869           1       520           close
  0.51    0.000158          31         5         1 futex
  0.08    0.000025           3         7           write
  0.07    0.000021           1        18           rt_sigprocmask
  0.06    0.000020           6         3           madvise
  0.05    0.000014           4         3           clone3
  0.04    0.000012           1         7         1 read
  0.03    0.000009           0        16        14 access
  0.02    0.000005           5         1           mprotect
  0.02    0.000005           1         3           set_robust_list
  0.01    0.000004           1         4           fcntl
  0.01    0.000002           2         1           pipe2
  0.01    0.000002           0         3           rseq
  0.00    0.000000           0         1           brk
  0.00    0.000000           0         6         6 readlink
  0.00    0.000000           0         1           restart_syscall
------ ----------- ----------- --------- --------- ----------------
100.00    0.030847          14      2193        43 total
```

# Without patch on sshfs over ethernet:

```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 71.52    0.041617        5945         7           poll
 15.77    0.009178           3      2557        21 newfstatat
  5.10    0.002970           5       516           openat
  4.55    0.002647           4       538           getdents64
  2.41    0.001405           2       520           close
  0.26    0.000153          19         8         1 futex
  0.21    0.000124           7        16        14 access
  0.06    0.000033          11         3           clone3
  0.03    0.000017           2         8           write
  0.02    0.000012           4         3           madvise
  0.02    0.000011           1         8         1 read
  0.02    0.000009           0        18           rt_sigprocmask
  0.01    0.000008           1         6         6 readlink
  0.01    0.000005           5         1           restart_syscall
  0.00    0.000002           0         3           set_robust_list
  0.00    0.000000           0         4           fcntl
  0.00    0.000000           0         1           pipe2
  0.00    0.000000           0         3           rseq
------ ----------- ----------- --------- --------- ----------------
100.00    0.058191          13      4220        43 total
```

# With patch on sshfs over ethernet:

```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 76.43    0.007975        1329         6           poll
 16.87    0.001760           1      1044      1021 newfstatat
  3.65    0.000381          14        26           getdents64
  0.68    0.000071          14         5         1 futex
  0.55    0.000057           9         6           write
  0.45    0.000047           5         9           close
  0.30    0.000031          10         3           madvise
  0.24    0.000025           3         7         1 read
  0.20    0.000021           4         5           openat
  0.18    0.000019           1        18           rt_sigprocmask
  0.15    0.000016           1        16        14 access
  0.11    0.000011           3         3           clone3
  0.04    0.000004           2         2           flock
  0.03    0.000003           3         1           mmap
  0.03    0.000003           0         6         6 readlink
  0.02    0.000002           0         4           fcntl
  0.02    0.000002           2         1           restart_syscall
  0.02    0.000002           0         3           set_robust_list
  0.02    0.000002           2         1           pipe2
  0.02    0.000002           0         3           rseq
  0.00    0.000000           0         1           lseek
------ ----------- ----------- --------- --------- ----------------
100.00    0.010434           8      1170      1043 total
```

On sshfs over flaky wifi, completions do not reliably appear. They show
eventually after hammering on \<tab\>, and the patched branch seems possibly
flakier than the packaged version (3.5.0).

In the packaged version, after the completions appear strace in non-counting
mode shows that the `openat()` sycalls continue for several seconds, at an
interval corresponding to a couple RTTs.  For some reason, this doesn't show up
in the usecs/call column with counting strace.  See strace\_wifi.txt and
strace\_wifi-patched.txt, collected with:

    sudo strace -r -f -p 394642 -e openat,%process --output=strace_wifi.txt

Strangely, when strace is used as in the patch commit message:

    strace -C -f -e openat fish --no-config -c 'complete -C "cd /tmp/completion_test/"' >/dev/null
   
`openat()` is not called for the subdirectories.  The same is true if `complete
-C "cd "` is used at an interactive prompt with strace attached.

# Why does interactive use call openat() when complete -C does not?

Attempts at getting perf and bpftrace to profile syscalls by userspace stacks
both failed. (See `perf_record_openat.fish`.) So we turn to the debugger. 

rr trace collected with procedure in `collect_debug_traces.fish`.

break on complete() and wopendir().

Observe that wopendir() is being called a bunch because the flag, `expand_flag::special_for_cd_autocomplete` is set. This flag is forwarded from `completer_t.flags.autosuggestion` in `completer_t::complete_param_expand` at complete.cpp:1064.

After investigation with gdb, it appears that `complete -C"cd "` 

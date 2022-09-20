#!/usr/bin/env fish

function setup_sshfs -w ssh -a remote
    set -l mountpoint "/tmp/completion_test_sshfs-$remote"
    mkdir -p $mountpoint
    ssh $remote fish <./create_problem.fish
    sshfs $remote:/tmp/completion_test $mountpoint
end

setup_sshfs knightfalcon # gigabit ethernet
setup_sshfs talonbolt    # wifi


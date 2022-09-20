#!/usr/bin/env fish

mkdir -p /tmp/completion_test
cd /tmp/completion_test

mkdir -p dir-(seq -w 100).(seq -w 10)
for dir in *
    touch $dir/(seq -w 10).file
end


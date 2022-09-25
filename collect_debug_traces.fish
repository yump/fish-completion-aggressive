#!/usr/bin/env fish

mkdir -p ./rr_traces

env -i rr record -o ./rr_traces/non_interactive ./fish-shell/build/fish \
    --no-config -c 'complete -C"cd /tmp/completion_test/"'

echo "
Please follow procedure:
  1. Paste into prompt \"cd /tmp/completion_test/\"
  2. Press <tab>
  3. Press ctrl+c
  4. Press ctrl+d"

env -i rr record -o ./rr_traces/interactive ./fish-shell/build/fish --no-config

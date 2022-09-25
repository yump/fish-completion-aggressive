#!/usr/bin/env fish

function build_fish -a checkout
    rm -r fish-shell/build
    mkdir -p fish-shell/build
    pushd fish-shell/build
    git checkout $checkout
    cmake -DCMAKE_BUILD_TYPE=Debug .. && make -j(nproc)
    popd
end

mkdir -p fish-bins
build_fish tags/3.5.1
cp fish-shell/build/fish fish-bins/fish-3.5.1
build_fish keep-dir-information
cp fish-shell/build/fish fish-bins/fish-patch

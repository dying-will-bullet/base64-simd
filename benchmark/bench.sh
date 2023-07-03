#!/bin/bash

set -ex

# generate data
(cd benchmark; python3 gen.py)

# build release
zig build -Doptimize=ReleaseFast

hyperfine -r 1000 -N --warmup 10 "./zig-out/bin/bench --std" "./zig-out/bin/bench --simd" --export-json benchmark/result.json

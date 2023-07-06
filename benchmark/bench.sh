#!/bin/bash

set -ex

# generate data
(cd benchmark; python3 gen.py)

# build release
zig build -Doptimize=ReleaseFast

echo "Start encoding benchmark..."
hyperfine -r 1000 -N --warmup 100 "./zig-out/bin/bench --encode --std" "./zig-out/bin/bench --encode --simd" --export-json benchmark/report/encode-report.json

echo "Start decoding benchmark..."
hyperfine -r 1000 -N --warmup 100 "./zig-out/bin/bench --decode --std" "./zig-out/bin/bench --decode --simd" --export-json benchmark/report/decode-report.json

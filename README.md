<h1 align="center"> base64-simd 🚀 </h1>

[![CI](https://github.com/dying-will-bullet/base64-simd/actions/workflows/ci.yaml/badge.svg)](https://github.com/dying-will-bullet/base64-simd/actions/workflows/ci.yaml)
![](https://img.shields.io/badge/language-zig-%23ec915c)

Make base64 encoding/decoding faster and simpler.
This is a Zig binding for [aklomp/base64](https://github.com/aklomp/base64),
accelerated with SIMD. It could encode at 1.45 times the speed of the standard library.

- [ base64-simd ](#-base64-simd--)
  - [Getting Started](#getting-started)
  - [API Reference](#api-reference)
    - [b64encode](#b64encode)
      - [Example](#example)
    - [b64decode](#b64decode)
      - [Example](#example-1)
    - [b64StreamEncoder](#b64streamencoder)
    - [b64StreamDecoder](#b64streamdecoder)
  - [Benchmark](#benchmark)
    - [Run the benchmark](#run-the-benchmark)
    - [Benchmark results](#benchmark-results)
      - [Environment](#environment)
      - [Encoding](#encoding)
      - [Decoding](#decoding)
  - [LICENSE](#license)

## Getting Started

There can be different installation ways, and here is an example of using submodules for installation.
Create a new project with `zig init-exe`. Then add this repo as a git submodule,
assuming that all your dependencies are stored in the `deps` directory.

```
$ mkdir deps && cd deps
$ git clone --recurse-submodules https://github.com/dying-will-bullet/base64-simd.git
```

Then add the following to your `build.zig`

```diff
diff --git a/build.zig b/build.zig
index 9faac30..4ecd5cb 100644
--- a/build.zig
+++ b/build.zig
@@ -1,4 +1,5 @@
 const std = @import("std");
+const base64 = @import("deps/base64-simd/build.zig");

 // Although this function looks imperative, note that its job is to
 // declaratively construct a build graph that will be executed by an external
@@ -24,6 +25,14 @@ pub fn build(b: *std.Build) void {
         .optimize = optimize,
     });

+    const base64_mod = b.addModule("base64", .{
+        .source_file = .{ .path = "deps/base64-simd/src/lib.zig" },
+    });
+    // Add the base64 module
+    exe.addModule("base64", base64_mod);
+    // Link
+    base64.buildAndLink(b, exe) catch @panic("Failed to link base64");
+
     // This declares intent for the executable to be installed into the
     // standard location when the user invokes the "install" step (the default
     // step when running `zig build`).
```

Edit `src/main.zig`

```zig
const std = @import("std");
const base64 = @import("base64");

pub fn main() !void {
    const s = "Hello World";

    var out: [32]u8 = undefined;
    const res = base64.b64encode(s, &out, .default);

    std.debug.print("{s}\n", .{res});
}
```

Execute `zig build run` and you will see the base64 encoded string of `Hello World`.

## API Reference

### b64encode

```zig
fn b64encode(
    s: []const u8,
    out: []u8,
    flag: Flag,
) []const u8
```

The `b64encode` function encodes a given input byte string `s` using Base64 encoding,
and stores the result in the `out`.
Set flags to `.default` for the default behavior, which is runtime feature detection on x86,
a compile-time fixed codec on ARM, and the plain codec on other platforms.
See more flags in `Flag` enum.

#### Example

```zig
    const s = "Hello World";

    var out: [32]u8 = undefined;
    const res = b64encode(s, &out, .default);

    try testing.expectEqualStrings("SGVsbG8gV29ybGQ=", res);
```

### b64decode

```zig
fn b64decode(
    s: []const u8,
    out: []u8,
    flag: Flag,
) ![]const u8
```

The `b64decode` function decodes a given Base64 encoded byte string `s`
and stores the result in the `out`. Returns abyte string representing the decoded data stored in the `out` buffer.

#### Example

```zig
    const s = "SGVsbG8gV29ybGQ=";

    var out: [32]u8 = undefined;
    const res = try b64decode(s, &out, .default);

    try testing.expectEqualStrings("Hello World", res);
```

### b64StreamEncoder

Similar to `b64encode`, but in stream.

```zig
    const s = [_][]const u8{ "H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d" };

    var out: [4]u8 = undefined;
    var encoder = b64StreamEncoder.init(.default);

    for (s) |c| {
        const part = encoder.encode(c, &out);
        std.debug.print("{s}", .{part});
    }

    std.debug.print("{s}\n", .{encoder.final(&out)});
```

### b64StreamDecoder

Similar to `b64decode`, but in stream.

```zig
    const s = [_][]const u8{
        "S", "G", "V", "s", "b", "G", "8", "g", "V", "2", "9", "y", "b", "G", "Q", "=",
    };

    var out: [4]u8 = undefined;
    var decoder = b64StreamDecoder.init(.default);

    for (s) |c| {
        const part = try decoder.decode(c, &out);
        std.debug.print("{s}", .{part});
    }
```

## Benchmark

### Run the benchmark

```
$ bash benchmark/bench.sh
```

The report will be generated in `benchmark/result.json`.

### Benchmark results

#### Environment

- ArchLinux 6.3.9-arch1-1
- CPU: AMD Ryzen 7 5800H with Radeon Graphics @ 16x 3.2GHz
- Zig: 0.11.0-dev.3739+939e4d81e, `-Doptimize=ReleaseFast`
- Benchmark Tools: hyperfine 1.17.0

#### Encoding

1000 rounds of testing, encoding 10000 records each time.

```
Command './zig-out/bin/bench --encode --std'
  runs:       1000
  mean:      0.039 s
  stddev:    0.001 s
  median:    0.039 s
  min:       0.037 s
  max:       0.051 s

  percentiles:
     P_05 .. P_95:    0.038 s .. 0.041 s
     P_25 .. P_75:    0.038 s .. 0.039 s  (IQR = 0.001 s)

Command './zig-out/bin/bench --encode --simd'
  runs:       1000
  mean:      0.027 s
  stddev:    0.002 s
  median:    0.026 s
  min:       0.025 s
  max:       0.067 s

  percentiles:
     P_05 .. P_95:    0.026 s .. 0.030 s
     P_25 .. P_75:    0.026 s .. 0.027 s  (IQR = 0.001 s)

```

#### Decoding

1000 rounds of testing, encoding 10000 records each time.

```
Command './zig-out/bin/bench --decode --std'
  runs:       1000
  mean:      0.042 s
  stddev:    0.003 s
  median:    0.041 s
  min:       0.039 s
  max:       0.104 s

  percentiles:
     P_05 .. P_95:    0.040 s .. 0.045 s
     P_25 .. P_75:    0.040 s .. 0.042 s  (IQR = 0.002 s)

Command './zig-out/bin/bench --decode --simd'
  runs:       1000
  mean:      0.036 s
  stddev:    0.003 s
  median:    0.035 s
  min:       0.033 s
  max:       0.101 s

  percentiles:
     P_05 .. P_95:    0.034 s .. 0.041 s
     P_25 .. P_75:    0.034 s .. 0.036 s  (IQR = 0.002 s)

```

<div>
<img align="left" width="400" height="400" src="https://github.com/dying-will-bullet/base64-simd/assets/9482395/9da58bd1-7466-4c02-9bac-f9fce043749f">
<img width="400" height="400" src="https://github.com/dying-will-bullet/base64-simd/assets/9482395/ba1f38de-8e56-408e-9715-4755c57ecba8">
</div>

## LICENSE

This repository is licensed under the BSD 2-clause License. See the LICENSE file.

1. [aklomp/base64 LICENSE](https://github.com/dying-will-bullet/base64-simd/blob/master/LICENSE)
2. [dying-will-bullet/base64-simd LICENSE](https://github.com/aklomp/base64/blob/master/LICENSE)

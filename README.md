<h1 align="center"> base64-simd 🚀 </h1>

[![CI](https://github.com/dying-will-bullet/base64-simd/actions/workflows/ci.yaml/badge.svg)](https://github.com/dying-will-bullet/base64-simd/actions/workflows/ci.yaml)
![](https://img.shields.io/badge/language-zig-%23ec915c)

Make base64 encoding/decoding faster and simpler.
This is a Zig binding for [aklomp/base64](https://github.com/aklomp/base64),
accelerated with SIMD. It could encode at 1.5 times the speed of the standard library.

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
- [LICENSE](#license)

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

- ArchLinux 6.3.9-arch1-1
- CPU: AMD Ryzen 7 5800H with Radeon Graphics @ 16x 3.2GHz
- Zig: 0.11.0-dev.3739+939e4d81e, `-Doptimize=ReleaseFast`
- Benchmark Tools: hyperfine 1.17.0

1000 rounds of testing, encoding 9990 records each time.

```
Command './zig-out/bin/bench --std'
  runs:       1000
  mean:      0.030 s
  stddev:    0.001 s
  median:    0.030 s
  min:       0.029 s
  max:       0.036 s

  percentiles:
     P_05 .. P_95:    0.029 s .. 0.032 s
     P_25 .. P_75:    0.030 s .. 0.031 s  (IQR = 0.001 s)

Command './zig-out/bin/bench --simd'
  runs:       1000
  mean:      0.019 s
  stddev:    0.001 s
  median:    0.019 s
  min:       0.018 s
  max:       0.024 s

  percentiles:
     P_05 .. P_95:    0.018 s .. 0.020 s
     P_25 .. P_75:    0.019 s .. 0.019 s  (IQR = 0.001 s)
```

<img width="400" height="400" src="https://github.com/dying-will-bullet/base64-simd/assets/9482395/72a93668-afdb-48b3-b33b-b7b30aed4659">

## LICENSE

This repository is licensed under the BSD 2-clause License. See the LICENSE file.

1. [aklomp/base64 LICENSE](https://github.com/dying-will-bullet/base64-simd/blob/master/LICENSE)
2. [dying-will-bullet/base64-simd LICENSE](https://github.com/aklomp/base64/blob/master/LICENSE)

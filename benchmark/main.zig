const std = @import("std");
const base64 = @import("base64");

fn runEncodeBench(use_std: bool) !usize {
    var file = try std.fs.cwd().openFile("./benchmark/testdata/encode-test-data", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var out: [2048]u8 = undefined;
    var count: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const s = if (use_std) blk: {
            break :blk std.base64.standard.Encoder.encode(&out, line);
        } else blk: {
            break :blk base64.b64encode(line, &out, .default);
        };
        _ = s;
        // std.debug.print("{s}\n", .{s});
        count += 1;
    }
    return count;
}

fn runDecodeBench(use_std: bool) !usize {
    var file = try std.fs.cwd().openFile("./benchmark/testdata/decode-test-data", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;
    var out: [2048]u8 = undefined;
    var count: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (use_std) {
            // const length = try std.base64.standard.Decoder.calcSizeForSlice(line);
            try std.base64.standard.Decoder.decode(&out, line);
            // break :blk out[0..length];
        } else {
            _ = try base64.b64decode(line, &out, .default);
        }
        count += 1;
    }
    return count;
}

pub fn main() !void {
    if (std.os.argv.len < 3) {
        std.debug.print("{s}\n", .{
            \\Run with:
            \\--encode --std
            \\--encode --simd
        });
        std.os.exit(1);
    }
    if (std.mem.eql(u8, std.mem.span(std.os.argv[1]), "--encode")) {
        if (std.mem.eql(u8, std.mem.span(std.os.argv[2]), "--std")) {
            std.debug.print("Start the std encoding benchmark\n", .{});
            _ = try runEncodeBench(true);
        } else {
            std.debug.print("Start the simd encoding benchmark\n", .{});
            _ = try runEncodeBench(false);
        }
    } else if (std.mem.eql(u8, std.mem.span(std.os.argv[1]), "--decode")) {
        if (std.mem.eql(u8, std.mem.span(std.os.argv[2]), "--std")) {
            std.debug.print("Start the std decoding benchmark\n", .{});
            _ = try runDecodeBench(true);
        } else {
            std.debug.print("Start the simd decoding benchmark\n", .{});
            _ = try runDecodeBench(false);
        }
    }
}

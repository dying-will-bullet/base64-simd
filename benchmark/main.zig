const std = @import("std");
const base64 = @import("base64");

fn runBench(use_std: bool) !usize {
    var file = try std.fs.cwd().openFile("./benchmark/data", .{});
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

pub fn main() !void {
    if (std.os.argv.len < 2) {
        std.debug.print("{s}\n", .{
            \\Run with:
            \\--std
            \\--simd
        });
        std.os.exit(1);
    }
    if (std.mem.eql(u8, std.mem.span(std.os.argv[1]), "--std")) {
        std.debug.print("run with --std\n", .{});
        _ = try runBench(true);
    } else {
        std.debug.print("run with --simd\n", .{});
        _ = try runBench(false);
    }
}

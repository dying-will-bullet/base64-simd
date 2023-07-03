const std = @import("std");
const testing = std.testing;

const clib = @cImport({
    @cInclude("libbase64.h");
});

pub const Error = error{
    InvalidInput,
};

pub const Flag = enum(c_int) {
    default = 0,
    avx2 = 1 << 0,
    neon32 = 1 << 1,
    neon64 = 1 << 2,
    plain = 1 << 3,
    ssse3 = 1 << 4,
    sse41 = 1 << 5,
    sse42 = 1 << 6,
    avx = 1 << 7,
    avx512 = 1 << 8,
};

// pub const LibBase64 = struct {
//     pub const State = extern struct {
//         eof: c_int,
//         bytes: c_int,
//         flags: c_int,
//         carry: u8,
//     };
//     pub extern fn base64_encode(src: [*]const u8, srclen: usize, out: [*]u8, outlen: *usize, flags: c_int) void;
//     pub extern fn base64_stream_encode_init(state: *State, flags: c_int) void;
//     pub extern fn base64_stream_encode(state: *State, src: [*]const u8, srclen: usize, out: [*]u8, outlen: *usize) void;
//     pub extern fn base64_stream_encode_final(state: *State, out: [*]u8, outlen: *usize) void;
//     pub extern fn base64_decode(src: [*]const u8, srclen: usize, out: [*]u8, outlen: *usize, flags: c_int) c_int;
//     pub extern fn base64_stream_decode_init(state: *State, flags: c_int) void;
//     pub extern fn base64_stream_decode(state: *State, src: [*]const u8, srclen: usize, out: [*]u8, outlen: *usize) c_int;
// };

pub fn b64encode(s: []const u8, out: []u8, flag: Flag) []const u8 {
    var out_len: usize = undefined;
    clib.base64_encode(s.ptr, s.len, out.ptr, &out_len, @intFromEnum(flag));

    return out[0..out_len];
}

pub fn b64decode(s: []const u8, out: []u8, flag: Flag) ![]const u8 {
    var out_len: usize = undefined;
    // Returns 1 for success,
    // and 0 when a decode error has occurred due to invalid input.
    // Returns -1 if the chosen codec is not included in the current build.
    const ret = clib.base64_decode(s.ptr, s.len, out.ptr, &out_len, @intFromEnum(flag));
    if (ret == 1) {
        return out[0..out_len];
    }
    if (ret == 0) {
        return error.InvalidInput;
    }
    if (ret == -1) {
        return error.InvalidInput;
    }
    unreachable;
}

test "base64 encode" {
    const s = "Hello World";

    var out: [32]u8 = undefined;
    const res = b64encode(s, &out, .default);

    try testing.expectEqualStrings("SGVsbG8gV29ybGQ=", res);
}

test "base64 decode" {
    const s = "SGVsbG8gV29ybGQ=";

    var out: [32]u8 = undefined;
    const res = try b64decode(s, &out, .default);

    try testing.expectEqualStrings("Hello World", res);
}

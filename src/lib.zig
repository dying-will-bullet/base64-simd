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

pub const b64StreamEncoder = struct {
    state: clib.struct_base64_state,
    flag: Flag,
    const Self = @This();

    pub fn init(flag: Flag) Self {
        var self = Self{
            .state = undefined,
            .flag = flag,
        };

        clib.base64_stream_encode_init(&self.state, @intFromEnum(flag));
        return self;
    }

    pub fn update(self: *Self, s: []const u8, out: []u8) []const u8 {
        var out_len: usize = undefined;
        clib.base64_stream_encode(&self.state, s.ptr, s.len, out.ptr, &out_len);
        return out[0..out_len];
    }

    pub fn final(self: *Self, out: []u8) []const u8 {
        var out_len: usize = undefined;
        clib.base64_stream_encode_final(&self.state, out.ptr, &out_len);
        return out[0..out_len];
    }
};

test "test b64StreamEncoder" {
    const allocator = testing.allocator;
    var res = std.ArrayList(u8).init(allocator);
    defer res.deinit();

    const s = [_][]const u8{ "H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d" };

    var out: [4]u8 = undefined;
    var encoder = b64StreamEncoder.init(.default);

    for (s) |c| {
        const part = encoder.update(c, &out);
        try res.appendSlice(part);
    }

    try res.appendSlice(encoder.final(&out));

    try testing.expectEqualStrings("SGVsbG8gV29ybGQ=", res.items);
}

pub const b64StreamDecoder = struct {
    state: clib.struct_base64_state,
    flag: Flag,
    const Self = @This();

    pub fn init(flag: Flag) Self {
        var self = Self{
            .state = undefined,
            .flag = flag,
        };

        clib.base64_stream_decode_init(&self.state, @intFromEnum(flag));
        return self;
    }

    pub fn update(self: *Self, s: []const u8, out: []u8) []const u8 {
        var out_len: usize = undefined;
        // TODO: error
        _ = clib.base64_stream_decode(&self.state, s.ptr, s.len, out.ptr, &out_len);
        return out[0..out_len];
    }
};

test "test b64StreamDecoder" {
    const allocator = testing.allocator;
    var res = std.ArrayList(u8).init(allocator);
    defer res.deinit();

    const s = [_][]const u8{
        "S", "G", "V", "s", "b", "G", "8", "g", "V", "2", "9", "y", "b", "G", "Q", "=",
    };

    var out: [4]u8 = undefined;
    var decoder = b64StreamDecoder.init(.default);

    for (s) |c| {
        const part = decoder.update(c, &out);
        try res.appendSlice(part);
    }

    try testing.expectEqualStrings("Hello World", res.items);
}

pub fn b64encode(s: []const u8, out: []u8, flag: Flag) []const u8 {
    var out_len: usize = undefined;

    clib.base64_encode(s.ptr, s.len, out.ptr, &out_len, @intFromEnum(flag));

    return out[0..out_len];
}

test "base64 encode" {
    const s = "Hello World";

    var out: [32]u8 = undefined;
    const res = b64encode(s, &out, .default);

    try testing.expectEqualStrings("SGVsbG8gV29ybGQ=", res);
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

test "base64 decode" {
    const s = "SGVsbG8gV29ybGQ=";

    var out: [32]u8 = undefined;
    const res = try b64decode(s, &out, .default);

    try testing.expectEqualStrings("Hello World", res);
}

const std = @import("std");

const pkg_name = "base64";
const pkg_path = "../src/lib.zig";

const examples = .{
    "src",
};

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    inline for (examples) |e| {
        const example_path = e ++ "/main.zig";
        const exe_name = "example-" ++ e;
        const run_name = "run-" ++ e;
        const run_desc = "Run the " ++ e ++ " example";

        const exe = b.addExecutable(.{
            .name = exe_name,
            .root_source_file = .{ .path = example_path },
            .target = target,
            .optimize = optimize,
        });
        const mod = b.addModule("base64", .{
            .source_file = .{ .path = "../src/lib.zig" },
        });
        exe.addModule("base64", mod);
        // TODO:
        exe.linkLibC();
        exe.addIncludePath("../deps/base64/include");
        exe.addObjectFile("../deps/base64/lib/libbase64.o");

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);

        run_cmd.step.dependOn(b.getInstallStep());
        const run_step = b.step(run_name, run_desc);
        run_step.dependOn(&run_cmd.step);
    }
}

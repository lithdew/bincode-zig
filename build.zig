const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("bincode", .{
        .root_source_file = b.path("bincode.zig"),
    });

    const lib = b.addStaticLibrary(.{
        .name = "bincode",
        .root_source_file = b.path("bincode.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_source_file = b.path("bincode.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}

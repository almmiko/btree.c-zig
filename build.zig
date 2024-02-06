const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("btree_c_zig", .{ .root_source_file = .{ .path = "src/btree.zig" } });

    const btree_c_lib = b.addStaticLibrary(.{
        .target = target,
        .name = "btree.c",
        .optimize = optimize,
    });

    const root = comptime std.fs.path.dirname(@src().file) orelse ".";

    btree_c_lib.addCSourceFiles(.{ .files = &.{root ++ "/vendor/btree.c/btree.c"} });
    btree_c_lib.addIncludePath(.{ .path = root ++ "/vendor/btree.c" });
    btree_c_lib.linkLibC();

    b.installArtifact(btree_c_lib);

    const btree_zig = b.addStaticLibrary(.{
        .name = "btree-zig",
        .root_source_file = .{ .path = "src/btree.zig" },
        .target = target,
        .optimize = optimize,
    });

    btree_zig.linkLibrary(btree_c_lib);
    btree_zig.addIncludePath(.{ .path = root ++ "/vendor/btree.c" });

    b.installArtifact(btree_zig);

    const btree_zig_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/btree.zig" },
        .target = target,
        .optimize = optimize,
    });

    btree_zig_tests.linkLibrary(btree_c_lib);
    btree_zig_tests.addIncludePath(.{ .path = root ++ "/vendor/btree.c" });

    const run_btree_zig_unit_tests = b.addRunArtifact(btree_zig_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_btree_zig_unit_tests.step);
}

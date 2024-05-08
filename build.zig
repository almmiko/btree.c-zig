const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_btree_c = b.dependency("btree_c", .{
        .target = target,
        .optimize = optimize,
    });

    const btree_zig = b.addStaticLibrary(.{
        .name = "btree-zig",
        .root_source_file = .{ .path = "src/btree.zig" },
        .target = target,
        .optimize = optimize,
    });

    btree_zig.linkLibC();

    btree_zig.addCSourceFiles(.{
        .root = dep_btree_c.path(""),
        .files = &.{"btree.c"},
    });

    btree_zig.installHeadersDirectory(dep_btree_c.path(""), "", .{
        .include_extensions = &.{"btree.h"},
    });

    const module = b.addModule("btree_c_zig", .{
        .root_source_file = .{ .path = "src/btree.zig" },
    });

    // Include header files from btree.c lib
    module.addIncludePath(dep_btree_c.path(""));

    b.installArtifact(btree_zig);

    const btree_zig_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/btree.zig" },
        .target = target,
        .optimize = optimize,
    });

    btree_zig_tests.linkLibrary(btree_zig);

    const run_btree_zig_unit_tests = b.addRunArtifact(btree_zig_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_btree_zig_unit_tests.step);
}

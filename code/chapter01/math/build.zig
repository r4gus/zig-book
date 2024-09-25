const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "mymath",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFiles(.{
        .files = &.{"src/math.c"},
        .flags = &.{"-std=gnu11"},
    });

    lib.addIncludePath(b.path("src"));
    lib.installHeader(b.path("src/math.h"), "mymath.h");

    lib.linkLibC();
    b.installArtifact(lib);
}

const std = @import("std");

pub fn build(b: *std.Build) void {
    const static = b.option(bool, "static", "Make a static library") orelse true;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = if (static) blk: {
        break :blk b.addStaticLibrary(.{
            .name = "hidapi",
            .target = target,
            .optimize = optimize,
        });
    } else blk: {
        break :blk b.addSharedLibrary(.{
            .name = "hidapi",
            .target = target,
            .optimize = optimize,
        });
    };

    if (target.result.os.tag == .linux) {
        lib.addCSourceFiles(.{
            .files = &.{"linux/hid.c"},
            .flags = &.{"-std=gnu11"},
        });

        // Manche Linux-Distros (z.B. OpenSuse) besitzen keine Developer-Package
        // von libudev, d.h. es fehlt die Datei `libudev.h`. In diesem Fall kann
        // die Datei manuell bezogen
        //    https://github.com/mcatalancid/libudev/blob/1.8.2/src/libudev.h
        // und in das Projekt integriert werden. In diesem Fall einfach die
        // folgende Zeile einfügen:
        lib.addSystemIncludePath(b.path("./"));

        // Abhängig von der Linux-Distor muss `udev` evtl. durch `libudev` ersetzt werden.
        lib.linkSystemLibrary("udev");
    } else {
        // An dieser Stelle wäre eine bessere Fehlerkommunikation angebracht.
        return;
    }

    // Der Unterordner ./hidapi enthält die `hidapi.h` Header-Datei
    lib.addIncludePath(b.path("hidapi"));
    lib.linkLibC();

    lib.installHeader(b.path("hidapi/hidapi.h"), "hidapi.h");

    b.installArtifact(lib);
}

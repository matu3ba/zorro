const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("zorro", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    // TODO test this and force user to make explicit decision what to use
    //const build_z3 = b.step("build_z3", "Build Z3, assumes Z3 is in folder z3");
    //{
    //    const z3_buildpath = "z3/build";
    //    fs.cwd().makePath(z3_buildpath) catch {}; // unconditionally create build folder
    //    const buildprep_cmd = b.addSystemCommand(&[_][]const u8{
    //        "cd",
    //        z3_buildpath,
    //        "; ",
    //        "CC='zig cc'" CXX='zig c++'",
    //        "cmake",
    //        "..",
    //        "-GNinja",
    //    });
    //    const build_cmd = b.addSystemCommand(&[_][]const u8{
    //        "cd",
    //        z3_buildpath,
    //        "; ",
    //        "ninja",
    //    });
    //    build_cmd.dependOn(&buildprep_cmd.step);
    //    build_z3.dependOn(&build_cmd.step);
    //}

    const z3_inc = "./z3/src/api";
    const z3_lib = "./z3/build";
    const proof_folder = "./src/pcrt";
    const exe = b.addExecutable("runProofs", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibCpp();
    exe.addIncludePath(z3_inc);
    exe.addLibPath(z3_lib);
    exe.linkSystemLibraryName("z3");
    exe.addIncludePath(proof_folder); // this also makes the header usable
    exe.addCSourceFile("src/pcrt/mulv.cpp", &[_][]const u8{});
    exe.addCSourceFile("src/pcrt/main.cpp", &[_][]const u8{});
    exe.install();

    const run_cmd = exe.run(); // returns *RunStep that can be used with step()
    run_cmd.step.dependOn(b.getInstallStep());
    //if (b.args) |args| {
    //    run_cmd.addArgs(args);
    //}
    const run_step = b.step("prove", "Run all proofs with Z3");
    run_step.dependOn(&run_cmd.step);

    // TODO make system libs usable
    // system lib paths, which pkg-config does not provide for inclusion
    //const z3_inc = "/usr/include";
    //const z3_lib = "/usr/lib";
    //const exe = b.addExecutable("example", null);
    //exe.setBuildMode(mode);
    //exe.install();
    //exe.linkLibCpp();
    //exe.addSystemIncludeDir(z3_inc);
    //exe.addLibPath(z3_lib);
    //exe.linkSystemLibraryName("z3");
    //exe.addCSourceFile("src/pcrt/min.cpp", &[_][]const u8{});
}

const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zorro",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.install();

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

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

    const z3_inc_c = "./z3/src/api";
    const z3_inc_cpp = "./z3/src/api/c++";
    const z3_lib = "./z3/build";
    const proof_folder = "./src/pcrt";
    const exe = b.addExecutable(.{
        .name = "runProofs",
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibCpp();
    exe.addIncludePath(z3_inc_c);
    exe.addIncludePath(z3_inc_cpp);
    exe.addLibraryPath(z3_lib);
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
    //const z3_inc_c = "/usr/include";
    //const z3_lib = "/usr/lib";
    //const exe = b.addExecutable("example", null);
    //exe.install();
    //exe.linkLibCpp();
    //exe.addSystemIncludeDir(z3_inc_c);
    //exe.addLibPath(z3_lib);
    //exe.linkSystemLibraryName("z3");
    //exe.addCSourceFile("src/pcrt/min.cpp", &[_][]const u8{});
}

const std = @import("std");

const sdl_source_dir = "deps/sdl";
const sdl_build_dir = sdl_source_dir ++ "/build";
const sdl_install_dir = sdl_source_dir ++ "/bin";
fn buildSDL(b: *std.Build) *std.Build.Step {
    const sdl_cmake_configure = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "-S", sdl_source_dir,
        "-B", sdl_build_dir,
        "-DSDL_VIDEO=ON",
        "-DSDL_WAYLAND=ON",
        "-DSDL_STATIC=ON",
        "-DSDL_TEST=OFF",
        "-DSDL_SHARED=OFF",
        "-DSDL_X11=ON",
        "-DSDL_VIDEO_VULKAN=ON",
        "-DSDL_VIDEO_OPENGL=ON",
        "-DCMAKE_INSTALL_PREFIX=" ++ sdl_install_dir,
    });

    const sdl_cmake_build = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "--build", sdl_build_dir,
        "--config", "Release"
    }); 
    sdl_cmake_build.step.dependOn(&sdl_cmake_configure.step);

    const sdl_cmake_install = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "--install", sdl_build_dir,
        "--config", "Release",
    });
    sdl_cmake_install.step.dependOn(&sdl_cmake_build.step);
    
    return &sdl_cmake_install.step;
}

fn dependSDL(b: *std.Build, target: *std.Build.Step.Compile) void {
    const sdl_install_step = buildSDL(b);
    target.step.dependOn(sdl_install_step);
    target.addLibraryPath(b.path(sdl_install_dir ++ "/lib64/libSDL3.a"));
    target.addIncludePath(b.path(sdl_install_dir ++ "/include"));
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create SDL3 dependency

    // Create Executable module
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Add executable
    const exe = b.addExecutable(.{
        .name = "zylo",
        .root_module = exe_mod,
    });
    dependSDL(b, exe);

    // Link cimgui

    // Install exe artifact
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

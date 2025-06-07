const std = @import("std");

const sdl_source_dir = "deps/sdl";
const sdl_build_dir = sdl_source_dir ++ "/build";
const sdl_install_dir = sdl_source_dir ++ "/bin";
fn buildSDL(b: *std.Build) *std.Build.Step {
    const sdl_cmake_configure = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "-S", sdl_source_dir,
        "-B", sdl_build_dir,
        "-DCMAKE_INSTALL_PREFIX=" ++ sdl_install_dir,
        "-DCMAKE_BUILD_TYPE=Debug",
    });

    const sdl_cmake_build = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "--build", sdl_build_dir,
        "--config", "Debug"
    }); 
    sdl_cmake_build.step.dependOn(&sdl_cmake_configure.step);

    const sdl_cmake_install = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "--install", sdl_build_dir,
        "--config", "Debug",
    });
    sdl_cmake_install.step.dependOn(&sdl_cmake_build.step);
    
    return &sdl_cmake_install.step;
}

fn dependSDL(b: *std.Build, target: *std.Build.Step.Compile) void {
    const sdl_install_step = buildSDL(b);
    target.step.dependOn(sdl_install_step);
    //const sdl_library = b.addStaticLibrary("sdl");
    //sdl_library.addLibraryPath(b.path(sdl_install_dir ++ "/lib64/libSDL3.a"));

    target.addLibraryPath(b.path(sdl_install_dir ++ "/lib64"));
    target.linkSystemLibrary("SDL3");
    target.linkSystemLibrary("wayland-client");
    target.linkSystemLibrary("wayland-cursor");
    target.linkSystemLibrary("wayland-egl");
    target.linkSystemLibrary("wayland-protocols");
    target.linkSystemLibrary("gbm");
    target.linkSystemLibrary("drm");
    target.linkSystemLibrary("glvnd");
    //target.linkSystemLibrary("decor");
    target.linkSystemLibrary("xdg-desktop-portal");
    target.addIncludePath(b.path(sdl_install_dir ++ "/include"));
}

fn linkWayland(target: *std.Build.Step.Compile) void {
    target.linkSystemLibrary("wayland-client");
    target.linkSystemLibrary("wayland-cursor");
    target.linkSystemLibrary("wayland-egl");
    target.linkSystemLibrary("wayland-protocols");
    target.linkSystemLibrary("gbm");
    target.linkSystemLibrary("drm");
    target.linkSystemLibrary("glvnd");
    target.linkSystemLibrary("xdg-desktop-portal");
}

fn generateWlrLayerShellClientProtocol(b: *std.Build, target: *std.Build.Step.Compile) void {
    const xmls = comptime [_][2][:0]const u8{
        .{ "xdg-shell", "protocol/xdg-shell.xml" },
        .{ "wlr-layer-shell", "protocol/wlr-layer-shell-unstable-v1.xml" },
    };

    inline for (xmls) |proto| {
        const name = proto[0];
        const path = proto[1];

        const header_out = b.pathJoin(&.{ "protocol/generated", name ++ "-client-protocol.h" });
        const code_out = b.pathJoin(&.{ "protocol/generated", name ++ "-protocol.c" });

        const header_cmd = b.addSystemCommand(&.{
            "wayland-scanner", "client-header", path, header_out
        });
        const code_cmd = b.addSystemCommand(&.{
            "wayland-scanner", "private-code", path, code_out
        });

        code_cmd.step.dependOn(&header_cmd.step);

        target.addIncludePath(b.path("protocol/generated/"));
        target.addCSourceFile(.{
            .file = b.path(code_out),
            .flags = &.{"-std=c99"},
        });

        target.step.dependOn(&header_cmd.step);
        target.step.dependOn(&code_cmd.step);
    }

    //const generate_header = b.addSystemCommand(&[_][]const u8{
    //    "wayland-scanner",
    //    "client-header",
    //    "protocol/wlr-layer-shell-unstable-v1.xml",
    //    "protocol/wlr-layer-shell/wlr-layer-shell-client-protocol.h"
    //});
    //const generate_source = b.addSystemCommand(&[_][]const u8{
    //    "wayland-scanner",
    //    "private-code",
    //    "protocol/wlr-layer-shell-unstable-v1.xml",
    //    "protocol/wlr-layer-shell/wlr-layer-shell-protocol.c"
    //});
    //generate_source.step.dependOn(&generate_header.step);
    //target.step.dependOn(&generate_source.step);

    //target.addIncludePath(b.path("protocol/wlr-layer-shell"));
    ////target.addCSourceFile(b.path("protocol/wlr-layer-shell/wlr-layer-shell-protocol.c"));
    //target.addCSourceFile(.{
    //    .file = b.path("protocol/wlr-layer-shell/wlr-layer-shell-protocol.c"),
    //    .flags = &.{
    //        "-std=c99",
    //        "-fPIC",
    //    },
    //});

    //target.installHeadersDirectory(b.path("protocol/wlr-layer-shell/"), "", .{});
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

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
    exe.linkLibC();
    exe.linkLibCpp();
    //dependSDL(b, exe);
    linkWayland(exe);
    generateWlrLayerShellClientProtocol(b, exe);

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

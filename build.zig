const std = @import("std");

pub const IMGUI_C_DEFINES: []const [2][]const u8 = &.{
    .{ "IMGUI_DISABLE_OBSOLETE_FUNCTIONS", "1" },
    .{ "IMGUI_DISABLE_OBSOLETE_KEYIO", "1" },
    .{ "IMGUI_IMPL_API", "extern \"C\"" },
    .{ "IMGUI_USE_WCHAR32", "1" },
    .{ "ImTextureID", "ImU64" },
    .{ "CIMGUI_USE_SDL2", "1" },
    .{ "IMGUI_DEFINE_MATH_OPERATORS", "1" },
};

pub const IMGUI_C_FLAGS: []const []const u8 = &.{
    "-std=c++11",
    "-fvisibility=hidden",
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    //const cimgui_dep = b.dependency("cimgui", .{});
    //const cimgui_path = cimgui_dep.path("");

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    //lib_mod.addCSourceFile(.{
    //    .file = try cimgui_path.join(b.allocator, "cimgui.cpp"),
    //    .flags = &[_][]const u8{},
    //});
    //lib_mod.addIncludePath(cimgui_path);

    // Add cimgui lib
    const sdl2_dep = b.dependency("sdl2", .{});

    const imgui_dep = b.dependency("imgui", .{});

    //const imguizmo_dep = b.dependency("imguizmo", .{});

    // Compile cimgui
    const imgui_lib = b.addStaticLibrary(.{
        .name = "imgui",
        .target = target,
        .optimize = optimize,
    });

    imgui_lib.root_module.link_libcpp = true;

    for (IMGUI_C_DEFINES) |c_define| {
        imgui_lib.root_module.addCMacro(c_define[0], c_define[1]);
    }

    const imgui_sources: []const std.Build.LazyPath = &.{
        //b.path("external/cimgui/cimguizmo.cpp"),
        b.path("deps/cimgui/cimgui.cpp"),
        imgui_dep.path("imgui.cpp"),
        imgui_dep.path("imgui_demo.cpp"),
        imgui_dep.path("imgui_draw.cpp"),
        imgui_dep.path("imgui_tables.cpp"),
        imgui_dep.path("imgui_widgets.cpp"),
        imgui_dep.path("backends/imgui_impl_sdl2.cpp"),
        imgui_dep.path("backends/imgui_impl_sdlrenderer2.cpp"),
        //imguizmo_dep.path("ImGuizmo.cpp"),
    };

    imgui_lib.addIncludePath(sdl2_dep.path("include"));
    //imgui_lib.addIncludePath(imguizmo_dep.path("."));
    imgui_lib.addIncludePath(b.path("deps/cimgui/"));
    imgui_lib.addIncludePath(imgui_dep.path("."));
    for (imgui_sources) |file| {
        imgui_lib.addCSourceFile(.{
            .file = file,
            .flags = IMGUI_C_FLAGS,
        });
    }

    // DELETE ME
    b.installArtifact(imgui_lib);

    // Create Executable module
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Add required imports
    exe_mod.addImport("zylo_lib", lib_mod);

    // Add library
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zylo",
        .root_module = lib_mod,
    });
    // Install lib artifact
    b.installArtifact(lib);

    // Add executable
    const exe = b.addExecutable(.{
        .name = "zylo",
        .root_module = exe_mod,
    });

    // Add cimgui includes
    exe.addIncludePath(b.path("deps/cimgui/"));
    exe.addIncludePath(sdl2_dep.path("include"));
    exe.addLibraryPath(sdl2_dep.path("lib/x64"));

    const p = sdl2_dep.path("lib/x64/SDL2.dll");

    const sdl_install_step = b.addInstallBinFile(p, "SDL2.dll");

    b.getInstallStep().dependOn(&sdl_install_step.step);

    exe.linkSystemLibrary("SDL2");
    exe.linkLibrary(imgui_lib);
    exe.linkLibC();

    // Install exe artifact
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

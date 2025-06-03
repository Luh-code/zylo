const std = @import("std");
const c_include = @import("c_inclde.zig");
const c = c_include.c;
const wayland_setup = @import("wayland/setup.zig");

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
    try wayland_setup.setupWayland();
    //const surface = c.wl_compositor_create_surface(compositor);
}

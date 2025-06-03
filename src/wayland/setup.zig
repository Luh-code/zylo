const std = @import("std");
const c = @import("../c_inclde.zig").c;
const data = @import("data.zig");

fn connectDisplay() !void {
    data.display = c.wl_display_connect(null) orelse return error.WaylandDisplayConnectionFailed;
}

fn getDisplayRegistry() !void {
    data.registry = c.wl_display_get_registry(data.display) orelse return error.WaylandRegistryRetrievalFailed;
}

fn registry_handler(name: u32, interface: []const u8) !void {
    if (std.mem.eql(u8, interface, "wl_compositor")) {
        data.compositor = c.wl_registry_bind(data.registry, name, &c.wl_compositor_interface, 4) orelse return error.WaylandRegistryBindingFailed;
    }
}

pub fn setupWayland() !void {
    try connectDisplay();
    try getDisplayRegistry();
    //try registry_handler(0, "zylo");
}


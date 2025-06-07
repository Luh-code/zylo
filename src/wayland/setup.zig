const std = @import("std");
const c = @import("../c_include.zig").c;
const data = @import("data.zig");

fn connectDisplay() !void {
    data.display = c.wl_display_connect(null) orelse return error.WaylandDisplayConnectionFailed;
}

fn getDisplayRegistry() !void {
    data.registry = c.wl_display_get_registry(data.display) orelse return error.WaylandRegistryRetrievalFailed;
}

fn handle_global(globalData: ?*anyopaque, registry: ?*c.wl_registry, name: u32, interface: [*c]const u8, version: u32) callconv(.C) void {
    const state: *data.RegistryState = @ptrCast(@alignCast(globalData));

    if (std.mem.eql(u8, std.mem.span(interface), "wl_compositor")) {
        state.compositor = @ptrCast(c.wl_registry_bind(registry, name, &c.wl_compositor_interface, @min(version, 4)));
    } else if (std.mem.eql(u8, std.mem.span(interface), "wl_shm")) {
        state.shm = @ptrCast(c.wl_registry_bind(registry, name, &c.wl_shm_interface, @min(version, 1)));
    } else if (std.mem.eql(u8, std.mem.span(interface), "zwlr_layer_shell_v1")) {
        state.layer_shell = @ptrCast(c.wl_registry_bind(registry, name, &c.zwlr_layer_shell_v1_interface, @min(version, 4)));
    }
}

fn handle_global_remove(globalData: ?*anyopaque, registry: ?*c.wl_registry, name: u32) callconv(.C) void {
    _ = globalData;
    _ = registry;
    _ = name;
}

const registry_listener = c.wl_registry_listener{
    .global = handle_global,
    .global_remove = handle_global_remove,
};

pub fn setupRegistry() !void {
    _ = c.wl_registry_add_listener(data.registry, &registry_listener, &data.registryState);

    _ = c.wl_display_roundtrip(data.display);

    if (data.registryState.compositor == null) {
        std.debug.print("Didn't get a wl_compositor\n", .{});
        return error.WaylandCompositorAquirementFailed;
    }

    std.debug.print("Aquired a wl_compositor at {*}\n", .{data.registryState.compositor});
}

pub fn setupWayland() !void {
    try connectDisplay();
    try getDisplayRegistry();
    try setupRegistry();
}

pub fn disconnectWayland() !void {
    c.wl_display_disconnect(data.display);
}

const c_include = @import("../c_include.zig");
const c = c_include.c;

pub const RegistryState = struct {
    compositor: ?*c.wl_compositor = null,
    shm: ?*c.wl_shm = null,
    layer_shell: ?*c.zwlr_layer_shell_v1 = null,
};

pub var registryState: RegistryState = RegistryState{};
pub var display: *c.wl_display = undefined;
pub var registry: *c.wl_registry = undefined;
pub var surface: *c.wl_surface = undefined;

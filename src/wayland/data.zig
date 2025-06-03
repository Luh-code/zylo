const c_include = @import("../c_inclde.zig");
const c = c_include.c;

pub var display: *c.wl_display = undefined;
pub var registry: *c.wl_registry = undefined;
pub var compositor: *c.wl_compositor = undefined;
pub var surface: *c.wl_surface = undefined;
pub var layer_surface: *c.zwlr_layer_surface_v1 = undefined;

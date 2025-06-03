pub const c = @cImport({
    //@cInclude("SDL3/SDL.h");
    @cInclude("wlr-layer-shell-client-protocol.h");
    @cInclude("wayland-client.h");
});

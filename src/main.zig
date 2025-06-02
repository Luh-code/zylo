const std = @import("std");

const c = @cImport({
    //@cInclude("SDL3/SDL.h");
});

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});
}

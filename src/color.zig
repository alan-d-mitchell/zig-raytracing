const std = @import("std");
const vec3 = @import("vec.zig").Vec3;

pub fn write_color(writer: anytype, pixel: vec3) !void {
    const r = pixel.get_x();
    const g = pixel.get_y();
    const b = pixel.get_z();

    const rbyte = @as(i32, @intFromFloat(255.999 * r));
    const gbyte = @as(i32, @intFromFloat(255.999 * g));
    const bbyte = @as(i32, @intFromFloat(255.999 * b));

    try writer.print("{d} {d} {d}\n", .{rbyte, gbyte, bbyte});
}

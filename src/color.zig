const std = @import("std");

const vec3 = @import("vec.zig").Vec3;
const interval = @import("interval.zig").Interval;

pub inline fn linear_to_gamma(linear_component: f64) f64 {
    if (linear_component > 0) return @sqrt(linear_component);

    return 0;
}

pub inline fn write_color(writer: anytype, pixel: vec3) !void {
    var r = pixel.get_x();
    var g = pixel.get_y();
    var b = pixel.get_z();

    // Apply a linear to gamma transformation for gamma 2 
    r = linear_to_gamma(r);
    b = linear_to_gamma(b);
    g = linear_to_gamma(g);

    // Translate the [0, 1] component values to the byte range [0, 255]
    const intensity = interval.new(0.000, 0.999);
    const rbyte = @as(i32, @intFromFloat(256.0 * intensity.clamp(r)));
    const gbyte = @as(i32, @intFromFloat(256.0 * intensity.clamp(g)));
    const bbyte = @as(i32, @intFromFloat(256.0 * intensity.clamp(b)));

    try writer.print("{d} {d} {d}\n", .{rbyte, gbyte, bbyte});
}

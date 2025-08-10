const std = @import("std");

const vec3 = @import("vec.zig").Vec3;
const color = @import("color.zig");
const ray = @import("ray.zig").Ray;
const hit = @import("hit.zig");
const hit_record = hit.HitRecord;
const hittable = hit.Hittable;
const hittables = @import("hittables.zig").Hittables;
const sphere = @import("sphere.zig").Sphere;
const interval = @import("interval.zig").Interval;
const camera = @import("camera.zig").Camera;

pub fn main() !void {
    var world = hittables.init(std.heap.page_allocator);
    defer world.deinit();

    const sphere1 = sphere.init(vec3.new(0, 0, -1), 0.5);
    const sphere2 = sphere.init(vec3.new(0, -100.5, -1), 100);

    try world.add(hittable {
        .sphere = sphere1,
    });

    try world.add(hittable {
        .sphere = sphere2,
    });

    var cam = camera {
        .image_height = undefined,
        .center = undefined,
        .pixel_00_location = undefined,
        .pixel_delta_u = undefined,
        .pixel_delta_v = undefined,
    };

    try cam.render(&world);
}

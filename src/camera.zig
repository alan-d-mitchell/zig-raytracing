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

pub const Camera = struct {
    const Self = @This();

    pub const aspect_ratio = 16.0 / 9.0;
    pub const image_width = 400;

    image_height: i32,
    center: vec3,
    pixel_00_location: vec3,
    pixel_delta_u: vec3,
    pixel_delta_v: vec3,

    pub fn initialize(self: *Self) void {
        self.image_height = @intFromFloat(@as(f64, @floatFromInt(image_width)) / aspect_ratio);
        if (self.image_height < 1) {
            self.image_height = 1;
        } else {
            self.image_height = self.image_height;
        }

        // set up camera
        self.center = vec3.new(0, 0, 0);
        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(self.image_height)));

        // calculate vectors across horizontal and down vertical viewport
        const viewport_u = vec3.new(viewport_width, 0, 0);
        const viewport_v = vec3.new(0, -viewport_height, 0);

        // calculate horizontal and vertical delta vectors from pixel to pixel
        self.pixel_delta_u = viewport_u.scale(1.0 / @as(f64, @floatFromInt(image_width)));
        self.pixel_delta_v = viewport_v.scale(1.0 / @as(f64, @floatFromInt(self.image_height)));

        const viewport_upper_left = self.center
        .subtract(vec3.new(0, 0, focal_length))
        .subtract(viewport_u.scale(0.5))
        .subtract(viewport_v.scale(0.5));

        self.pixel_00_location = viewport_upper_left.add(
        self.pixel_delta_u.add(self.pixel_delta_v).scale(0.5)
    );
    }

    pub fn render(self: *Self, world: *const hittables) !void {
        self.initialize();

        const file = try std.fs.cwd().createFile("image.ppm", .{});
        defer file.close();
        const writer = file.writer();

        try writer.print("P3\n{d} {d}\n255\n", .{ image_width, self.image_height });
        
        for (0..@intCast(self.image_height)) |j| {
            for (0..image_width) |i| {
                const pixel_center = self.pixel_00_location
                    .add(self.pixel_delta_u.scale(@floatFromInt(i)))
                    .add(self.pixel_delta_v.scale(@floatFromInt(j)));

                const ray_direction = pixel_center.subtract(self.center);
                const r = ray.init(self.center, ray_direction);
                const pixel_color = ray_color(r, world);

                try color.write_color(writer, pixel_color);
            }
        }
    }

    pub fn ray_color(r: ray, world: *const hittables) vec3 {
        var rec: hit_record = hit_record.init();

        if (world.hit(r, interval.new(0, std.math.inf(f64)), &rec)) {
            return rec.normal.add(vec3.new(1, 1, 1).scale(0.5));
        }

        const unit_direction: vec3 = r.direction().normalize();
        const a = 0.5 * (unit_direction.get_y() + 1.0);
        const white = vec3.new(1.0, 1.0, 1.0);
        const blue = vec3.new(0.5, 0.7, 1.0);

        return white.scale(1.0 - a).add(blue.scale(a));
    }
};

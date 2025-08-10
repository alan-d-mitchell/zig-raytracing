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
const math = @import("utils.zig").Math;
const random = @import("utils.zig").Random;

pub const Camera = struct {
    const Self = @This();

    pub const aspect_ratio = 16.0 / 9.0;
    pub const image_width = 400; 
    pub const samples_per_pixel = 50; // Count of random samples per pixel
    pub const max_depth = 25; // Max number of ray bounces into scene

    image_height: i32,
    pixel_samples_scale: f64,
    center: vec3,
    pixel_00_location: vec3,
    pixel_delta_u: vec3,
    pixel_delta_v: vec3,

    pub fn initialize(self: *Self) void {
        self.image_height = @intFromFloat(@as(f64, @floatFromInt(image_width)) / aspect_ratio);
        if (self.image_height < 1) { self.image_height = 1; } else { self.image_height = self.image_height; }

        self.pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(samples_per_pixel));

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

    pub fn sample_square() vec3 {
        return vec3.new(
            random.random_number(&random.rng) - 0.5, 
            random.random_number(&random.rng) - 0.5, 
            0
        );
    }

    pub fn get_ray(self: *Self, i: i32, j: i32) ray {
        // construct a camera ray originating from the origin
        // directed at the randomly sampled point around the pixel location i, j

        const offset = sample_square();
        const pixel_sample = self.pixel_00_location
            .add(self.pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.get_x()))
            .add(self.pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.get_y())
        );

        const ray_origin = self.center;
        const ray_direction = pixel_sample.subtract(ray_origin);

        return ray.init(ray_origin, ray_direction);
    }

    pub fn render(self: *Self, world: *const hittables) !void {
        self.initialize();

        const file = try std.fs.cwd().createFile("image.ppm", .{});
        defer file.close();
        const writer = file.writer();
        const stderr = std.io.getStdErr().writer();

        try writer.print("P3\n{d} {d}\n255\n", .{ image_width, self.image_height });

        for (0..@intCast(self.image_height)) |j| {
            try stderr.print("\rScanlines remaining: {d} ", .{ self.image_height - @as(i32, @intCast(j)) });

            for (0..image_width) |i| {
                var pixel_color = vec3.new(0, 0, 0);

                for (0..@intCast(samples_per_pixel)) |_| {
                    const r = self.get_ray(@intCast(i), @intCast(j));
                    pixel_color = pixel_color.add(ray_color(r, max_depth, world));
                }

                try color.write_color(writer, pixel_color.scale(self.pixel_samples_scale));
            }
        }
        try stderr.print("\rDone                        \n", .{});
    }

    pub fn ray_color(r: ray, depth: i32, world: *const hittables) vec3 {
        // If exceeded ray bounce limit, no more light
        if (depth <= 0) return vec3.zero();

        var rec: hit_record = hit_record.init();

        if (world.hit(r, interval.new(0.001, std.math.inf(f64)), &rec)) {
            const direction = rec.normal.add(vec3.random_normalize());

            return ray_color(ray.init(rec.p, direction), depth - 1, world).scale(0.3);
        }

        const unit_direction: vec3 = r.direction().normalize();
        const a = 0.5 * (unit_direction.get_y() + 1.0);
        const white = vec3.new(1.0, 1.0, 1.0);
        const blue = vec3.new(0.5, 0.7, 1.0);
        
        return white.scale(1.0 - a).add(blue.scale(a));
    }
};

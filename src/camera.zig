const std = @import("std");

const vec3 = @import("vec.zig").Vec3;
const color = @import("color.zig");
const ray = @import("ray.zig").Ray;
const hit_record = @import("hit.zig").HitRecord;
const hittable = @import("hit.zig").Hittable;
const hittables = @import("hittables.zig").Hittables;
const sphere = @import("sphere.zig").Sphere;
const interval = @import("interval.zig").Interval;
const math = @import("utils.zig").Math;
const random = @import("utils.zig").Random;
const material = @import("material.zig");

pub const Camera = struct {
    const Self = @This();

    aspect_ratio: f64,
    image_width: usize, 
    samples_per_pixel: i32, // Count of random samples per pixel
    max_depth: i32, // Max number of ray bounces into scene
    vfov: f64, // Vertical FOV
    look_from: vec3,
    look_at: vec3,
    vup: vec3, // relative up direction of cam 
    defocus_angle: f64, // variation angle of rays
    focus_dist: f64, // distance from camera look_from point to plane of perfect focus

    // These need to be non field members
    pub var image_height: i32 = undefined;
    pub var pixel_samples_scale: f64 = undefined;
    pub var center: vec3 = undefined;
    pub var pixel_00_location: vec3 = undefined;
    pub var pixel_delta_u: vec3 = undefined;
    pub var pixel_delta_v: vec3 = undefined;
    pub var u: vec3 = undefined;
    pub var v: vec3 = undefined;
    pub var w: vec3 = undefined;
    pub var defocus_disk_u: vec3 = undefined;
    pub var defocus_disk_v: vec3 = undefined;

    pub inline fn initialize(self: *Self) void {
        image_height = @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio);
        if (image_height < 1) { image_height = 1; } else { image_height = image_height; }

        pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(self.samples_per_pixel));

        // set up camera
        center = self.look_from;
        const theta = math.degrees_to_radians(self.vfov);
        const h = @tan(theta / 2);
        const viewport_height = 2.0 * h * self.focus_dist;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(self.image_width)) / @as(f64, @floatFromInt(image_height)));

        // calculate u, v, w unit basis vectors for camera coordinate frame
        w = self.look_from.subtract(self.look_at).normalize();
        u = self.vup.cross(w).normalize();
        v = w.cross(u);

        // calculate vectors across horizontal and down vertical viewport
        const viewport_u = u.scale(viewport_width);
        const viewport_v = v.scale(-viewport_height);

        // calculate horizontal and vertical delta vectors from pixel to pixel
        pixel_delta_u = viewport_u.scale(1.0 / @as(f64, @floatFromInt(self.image_width)));
        pixel_delta_v = viewport_v.scale(1.0 / @as(f64, @floatFromInt(image_height)));

        const viewport_upper_left = center
            .subtract(w.scale(self.focus_dist))
            .subtract(viewport_u.scale(0.5))
            .subtract(viewport_v.scale(0.5));

        pixel_00_location = viewport_upper_left.add(
            pixel_delta_u.add(pixel_delta_v).scale(0.5)
        );

        // calculate the camera defocus disk basis vectors
        const defocus_radius = self.focus_dist * @tan(math.degrees_to_radians(self.defocus_angle / 2));
        defocus_disk_u = u.scale(defocus_radius);
        defocus_disk_v = v.scale(defocus_radius);
    }

    pub inline fn sample_square() vec3 {
        return vec3.new(
            random.random_number(&random.rng) - 0.5, 
            random.random_number(&random.rng) - 0.5, 
            0
        );
    }

    pub inline fn get_ray(self: *Self, i: i32, j: i32) ray {
        // construct a camera ray originating from the origin
        // directed at the randomly sampled point around the pixel location i, j

        const offset = sample_square();
        const pixel_sample = pixel_00_location
            .add(pixel_delta_u.scale(@as(f64, @floatFromInt(i)) + offset.get_x()))
            .add(pixel_delta_v.scale(@as(f64, @floatFromInt(j)) + offset.get_y())
        );

        const ray_origin = if (self.defocus_angle <= 0)
            center
        else 
            defocus_disk_sample();
        const ray_direction = pixel_sample.subtract(ray_origin);

        return ray.init(ray_origin, ray_direction);
    }

    pub inline fn defocus_disk_sample() vec3 {
        const p = vec3.random_in_unit_disk();

        return center
            .add(defocus_disk_u.scale(p.get_x()))
            .add(defocus_disk_v.scale(p.get_y())
        );
    }

    pub inline fn render(self: *Self, world: *const hittables) !void {
        self.initialize();

        const file = try std.fs.cwd().createFile("image.ppm", .{});
        defer file.close();
        const writer = file.writer();
        const stderr = std.io.getStdErr().writer();

        try writer.print("P3\n{d} {d}\n255\n", .{ self.image_width, image_height });

        for (0..@intCast(image_height)) |j| {
            try stderr.print("\rScanlines remaining: {d} ", .{ image_height - @as(i32, @intCast(j)) });

            for (0..@intCast(self.image_width)) |i| {
                var pixel_color = vec3.new(0, 0, 0);

                for (0..@intCast(self.samples_per_pixel)) |_| {
                    const r = get_ray(self, @intCast(i), @intCast(j));
                    pixel_color = pixel_color.add(ray_color(r, self.max_depth, world));
                }

                try color.write_color(writer, pixel_color.scale(pixel_samples_scale));
            }
        }
        try stderr.print("\rDone                        \n", .{});
    }

    pub fn ray_color(r: ray, depth: i32, world: *const hittables) vec3 {
        // If exceeded ray bounce limit, no more light
        if (depth <= 0) return vec3.zero();

        var rec: hit_record = hit_record.init();

        if (world.hit(r, interval.new(0.001, std.math.inf(f64)), &rec)) {
            var scattered: ray = undefined;
            var attenuation: vec3 = undefined;
            
            if (rec.mat.scatter(r, &rec, &attenuation, &scattered)) {
                return attenuation.multiply(ray_color(scattered, depth - 1, world));
            }

            return vec3.zero();
        }

        const unit_direction: vec3 = r.direction().normalize();
        const a = 0.5 * (unit_direction.get_y() + 1.0);
        const white = vec3.new(1.0, 1.0, 1.0);
        const blue = vec3.new(0.5, 0.7, 1.0);
        
        return white.scale(1.0 - a).add(blue.scale(a));
    }
};

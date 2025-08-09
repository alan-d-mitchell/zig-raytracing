const std = @import("std");
const vec3 = @import("vec.zig").Vec3;
const color = @import("color.zig");
const ray = @import("ray.zig").Ray;

pub fn hit_sphere(center: vec3, radius: f64, r: ray) f64 {
    const oc: vec3 = r.origin().subtract(center);
    const a = r.direction().dot(r.direction());
    const h = oc.dot(r.direction());
    const c = oc.length_squared() - radius * radius;
    const discrim = h * h - a * c;

    if (discrim < 0) {
        return -1.0;
    } else {
        return (-h - @sqrt(discrim)) / a;
    }
}

pub fn ray_color(r: ray) vec3 {
    const sphere_center = vec3.new(0, 0, -1);
    const t = hit_sphere(sphere_center, 0.5, r);
    if (t > 0.0) {
        const N: vec3 = r.at(t).subtract(sphere_center).normalize();

        return vec3.new(N.get_x() + 1, N.get_y() + 1, N.get_z() + 1).scale(0.5);
    }

    const unit_direction: vec3 = r.direction().normalize();
    const a = 0.5 * (unit_direction.get_y() + 1.0);

    const white = vec3.new(1.0, 1.0, 1.0);
    const blue = vec3.new(0.5, 0.7, 1.0);

    return white.scale(1.0 - a).add(blue.scale(a));
}

pub fn main() !void {
    const aspect_ratio = 16.0 / 9.0;
    const image_width = @as(f64, 400);

    var image_height = (image_width / aspect_ratio); // Calculate image height 
    if (image_height < 1) { image_height = 1; } else { image_height = image_height; } // Ensure height is at least 1 
    
    // set up camera 
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * @as(f64, image_width / image_height);
    const camera_center = vec3.new(0, 0, 0);

    // calculate vectors across horizontal and down the vertical viewport edges
    const viewport_u = vec3.new(viewport_width, 0, 0);
    const viewport_v = vec3.new(0, -viewport_height, 0);

    // calculate horizontal and vertical delta vectors from pixel to pixel
    const pixel_delta_u = viewport_u.scale(1.0 / image_width);
    const pixel_delta_v = viewport_v.scale(1.0 / image_height);

    // calculate location of upper left pixel
    const viewport_upper_left = camera_center
        .subtract(vec3.new(0, 0, focal_length))
        .subtract(viewport_u.scale(0.5))
        .subtract(viewport_v.scale(0.5));

    const pixel_00_location = viewport_upper_left.add(
        pixel_delta_u.add(pixel_delta_v).scale(0.5));

    const file = try std.fs.cwd().createFile("image.ppm", .{});
    defer file.close();
    const writer = file.writer();

    try writer.print("P3\n{d} {d}\n255\n", .{ @as(i32, @intFromFloat(image_width)), @as(i32, @intFromFloat(image_height)) });

    for (0..@as(usize, @intFromFloat(image_height))) |j| {
        std.debug.print("\rScanlines remaining: {d}   ", .{ @as(usize, @intFromFloat(image_height)) - j});

        for (0..@as(usize, @intFromFloat(image_width))) |i| {
            const pixel_center = pixel_00_location
                .add(pixel_delta_u.scale(@as(f64, @floatFromInt(i))))
                .add(pixel_delta_v.scale(@as(f64, @floatFromInt(j))));
            const ray_direction = pixel_center.subtract(camera_center);
            const r = ray.init(camera_center, ray_direction);

            //const r = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(image_width - 1));
            //const g = @as(f64, @floatFromInt(j)) / @as(f64, @floatFromInt(image_height - 1));
            //const b = 0.0;

            const pixel_color = ray_color(r);
            try color.write_color(writer, pixel_color);
        }
   }
}

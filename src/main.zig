const std = @import("std");

const vec3 = @import("vec.zig").Vec3;
const color = @import("color.zig");
const ray = @import("ray.zig").Ray;
const hit_record = @import("hit.zig").HitRecord;
const hittable = @import("hit.zig").Hittable;
const hittables = @import("hittables.zig").Hittables;
const sphere = @import("sphere.zig").Sphere;
const interval = @import("interval.zig").Interval;
const camera = @import("camera.zig").Camera;
const material = @import("material.zig");
const random = @import("utils.zig").Random;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var world = hittables.init(allocator);
    defer world.deinit();

    var material_list = std.ArrayList(material.Material).init(allocator);
    defer material_list.deinit();
    try material_list.ensureTotalCapacity(500);

    try material_list.append(material.Material {
        .lambertian = material.Lambertian.init(vec3.new(0.5, 0.5, 0.5))     
    });     
    const ground_material = &material_list.items[material_list.items.len - 1];
    
    try world.add(hittable {
        .sphere = sphere.init(vec3.new(0, -1000, 0), 1000, ground_material)
    });

    var a: i32 = -11;
    while (a < 11) : (a += 1) {
        var b: i32 = -11;
        
        while (b < 11) : (b += 1) {
            const choose_mat = random.random_number(&random.rng);
            const center = vec3.new(
                @as(f64, @floatFromInt(a)) + 0.9 * random.random_number(&random.rng),
                0.2,
                @as(f64, @floatFromInt(b)) + 0.9 * random.random_number(&random.rng)
            );

            if (center.subtract(vec3.new(4, 0.2, 0)).length() > 0.9) {
                if (choose_mat < 0.8) {
                    // Diffuse
                    const albedo = vec3.random().multiply(vec3.random());
                    try material_list.append(material.Material {
                        .lambertian = material.Lambertian.init(albedo) 
                    });

                    const sphere_material = &material_list.items[material_list.items.len - 1];
                    try world.add(hittable {
                        .sphere = sphere.init(center, 0.2, sphere_material)
                    });
                } else if (choose_mat < 0.95) {
                    // Metal
                    const albedo = vec3.random_within_range(0.5, 1);
                    const fuzz = random.random_range(&random.rng, 0, 0.5);
                    try material_list.append(material.Material { 
                        .metal = material.Metal.init(albedo, fuzz) 
                    });

                    const sphere_material = &material_list.items[material_list.items.len - 1];
                    try world.add(hittable { 
                        .sphere = sphere.init(center, 0.2, sphere_material) 
                    });
                } else {
                    // Glass
                    try material_list.append(material.Material { 
                        .dielectric = material.Dielectric.init(1.5) 
                    });

                    const sphere_material = &material_list.items[material_list.items.len - 1];
                    try world.add(hittable { 
                        .sphere = sphere.init(center, 0.2, sphere_material) 
                    });
                }
            }
        }
    }

    // three large spheres
    try material_list.append(material.Material { 
        .dielectric = material.Dielectric.init(1.5) 
    });
    const mat1 = &material_list.items[material_list.items.len - 1];
    try world.add(hittable { 
        .sphere = sphere.init(vec3.new(0, 1, 0), 1.0, mat1) 
    });

    try material_list.append(material.Material { 
        .lambertian = material.Lambertian.init(vec3.new(0.4, 0.2, 0.1)) 
    });
    const mat2 = &material_list.items[material_list.items.len - 1];
    try world.add(hittable { 
        .sphere = sphere.init(vec3.new(-4, 1, 0), 1.0, mat2) 
    });

    try material_list.append(material.Material { 
        .metal = material.Metal.init(vec3.new(0.7, 0.6, 0.5), 0.0) 
    });
    const mat3 = &material_list.items[material_list.items.len - 1];
    try world.add(hittable { 
        .sphere = sphere.init(vec3.new(4, 1, 0), 1.0, mat3) 
    });

    var cam = camera {
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 1200,
        .samples_per_pixel = 100,
        .max_depth = 100,
        .vfov = 20,
        .look_from = vec3.new(13, 2, 3),
        .look_at = vec3.zero(),
        .vup = vec3.new(0, 1, 0),
        .defocus_angle = 0.6,
        .focus_dist = 10.0,
    };

    try cam.render(&world);
}

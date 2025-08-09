const std = @import("std");
const vec3 = @import("vec.zig").Vec3;
const ray = @import("ray.zig").Ray;
const sphere = @import("sphere.zig").Sphere;

// struct to hold record of hit, very straightforward
pub const HitRecord = struct {
    p: vec3,
    normal: vec3,
    t: f64,

    pub fn init() HitRecord {
        return HitRecord {
            .p = vec3.zero(),
            .normal = vec3.zero(),
            .t = 0.0,
        };
    }
};

// 
pub const Hittable = union(enum) {
    sphere: sphere,

    pub fn hit(self: Hittable, r: ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
        switch (self) {
            .sphere => |_sphere| return _sphere.hit(r, ray_tmin, ray_tmax, rec),
        }
    }
};


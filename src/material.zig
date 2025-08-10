const std = @import("std");

const hittable = @import("hit.zig").Hittable;
const hit_record = @import("hit.zig").HitRecord;
const ray = @import("ray.zig").Ray;
const vec3 = @import("vec.zig").Vec3;

pub const Material = struct {
    pub fn init() Material {
        return Material {

        };
    }

    pub fn scatter(r_in: ray, rec: hit_record, attenuation: vec3, scattered: ray) bool {
                
        return false;
    }
};

pub const Lambertian = struct {
    
};

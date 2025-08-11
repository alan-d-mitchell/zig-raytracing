const std = @import("std");

const hittable = @import("hit.zig").Hittable;
const hit_record = @import("hit.zig").HitRecord;
const ray = @import("ray.zig").Ray;
const vec3 = @import("vec.zig").Vec3;
const rand = @import("utils.zig").Random;

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

    pub fn scatter(self: Material, r_in: ray, rec: *const hit_record, attenuation: *vec3, scattered: *ray) bool {
        switch (self) {
            .lambertian => |l| return l.scatter(r_in, rec, attenuation, scattered),
            .metal => |m| return m.scatter(r_in, rec, attenuation, scattered),
            .dielectric => |d| return d.scatter(r_in, rec, attenuation, scattered),
        } 
    }
};

pub const Lambertian = struct {
    albedo: vec3,

    pub fn init(albedo: vec3) Lambertian {
        return Lambertian {
            .albedo = albedo,
        };
    }
    
    pub fn scatter(self: Lambertian, r_in: ray, rec: *const hit_record, attenuation: *vec3, scattered: *ray) bool {
        _ = r_in; // unused param
        
        // Generate random unit vector
        var scatter_direction = rec.normal.add(vec3.random_normalize());

        if (scatter_direction.near_zero()) {
            scatter_direction = rec.normal;
        }

        scattered.* = ray.init(rec.p, scatter_direction);
        attenuation.* = self.albedo;

        return true; 
    }
};

pub const Metal = struct {
    albedo: vec3,
    fuzz: f64,

    pub fn init(albedo: vec3, fuzz: f64) Metal {
        return Metal {
            .albedo = albedo,
            .fuzz = fuzz,
        };
    }

    pub fn scatter(self: Metal, r_in: ray, rec: *const hit_record, attenuation: *vec3, scattered: *ray) bool {
        const reflected = vec3.reflect(r_in.direction().normalize(), rec.normal);
        scattered.* = ray.init(rec.p, reflected.add(vec3.random_normalize().scale(self.fuzz)));
        attenuation.* = self.albedo;

        return scattered.direction().dot(rec.normal) > 0;
    }
};

pub const Dielectric = struct {
    // refractive index in vacuum or air, or the ratio of materials refractive index
    // over the refractive index of the enclosing media
    refraction_index: f64,

    pub fn init(refraction_index: f64) Dielectric {
        return Dielectric {
            .refraction_index = refraction_index,
        };
    }
    
     
    pub fn reflectance(cosine: f64, refraction_index: f64) f64 {
        // Schlicks approximation for reflectance
        var r0 = (1 - refraction_index) / (1 + refraction_index);
        r0 = r0 * r0;

        return r0 + (1 - r0) * std.math.pow(f64, 1 - cosine, 5);
    }

    pub fn scatter(self: Dielectric, r_in: ray, rec: *const hit_record, attenuation: *vec3, scattered: *ray) bool {
        attenuation.* = vec3.new(1.0, 1.0, 1.0);
        
        const ri = if (rec.front_face)
            (1.0 / self.refraction_index)
        else 
            self.refraction_index;

        const unit_direction = r_in.direction().normalize();

        const cos_theta = -@min(rec.normal.dot(unit_direction), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

        const no_refract = ri * sin_theta > 1.0;
        var direction = vec3.zero();

        if (no_refract or reflectance(cos_theta, ri) > rand.random_number(&rand.rng)) {
            // Must REFLECT if total internal reflection occurs
            direction = vec3.reflect(unit_direction, rec.normal);
        } else {
            // Refract if possible
            direction = vec3.refract(unit_direction, rec.normal, ri);
        }

        scattered.* = ray.init(rec.p, direction);

        return true;
    }
};

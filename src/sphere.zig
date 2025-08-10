const std = @import("std");
const hittable = @import("hit.zig");
const ray = @import("ray.zig").Ray;
const vec3 = @import("vec.zig").Vec3;
const interval = @import("interval.zig").Interval;
const material = @import("material.zig").Material;

pub const Sphere = struct {
    center: vec3,
    radius: f64,
    mat: *material,

    pub fn init(center: vec3, radius: f64, mat: *material) Sphere {
        return Sphere {
            .center = center,
            .radius = @max(0.0, radius),
            .mat = mat,
        };
    }

    pub fn hit(self: Sphere, r: ray, ray_t: interval, rec: *hittable.HitRecord) bool {
        const oc = r.origin().subtract(self.center);
        const a = r.direction().length_squared();
        const h = r.direction().dot(oc);
        const c = oc.length_squared() - self.radius * self.radius;

        const discriminant = h * h - a * c;
        if (discriminant < 0) return false;

        const sqrtd = @sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range
        var root = (h - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (h + sqrtd) / a;

            if (!ray_t.surrounds(root)) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.subtract(self.center).scale(1.0 / self.radius);
        rec.set_face_normal(r, outward_normal);
        rec.mat = self.mat;

        return true;
    }
};

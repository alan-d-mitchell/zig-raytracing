const std = @import("std");
const hittable = @import("hit.zig");
const vec3 = @import("vec.zig").Vec3;

pub const Sphere = struct {
    center: vec3,
    radius: f64,

    pub fn init(center: vec3, radius: f64) Sphere {
        return Sphere {
            .center = center,
            .radius = @max(0.0, radius),
        };
    }

    pub fn hit(self: Sphere, r: ray, ray_tmin: f64, ray_tmax: f64, rec: *hittable.HitRecord) bool {
        const oc = self.center.subtract(r.origin());
        const a = r.direction().length_squared();
        const h = r.direction().dot(oc);
        const c = oc.length_squared() - self.radius * self.radius;

        const discriminant = h * h - a * c;
        if (discriminant < 0) return false;

        const sqrtd = @sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range
        var root = (h - sqrtd) / a;
        if (root <= ray_tmin or ray_tmax <= root) {
            root = (h + sqrtd) / a;
            if (root <= ray_tmin or ray_tmax <= root) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        rec.normal = rec.p.subtract(self.center).scale(1.0 / self.radius);

        return true;
    }
};

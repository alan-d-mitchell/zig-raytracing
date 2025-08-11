const std = @import("std");
const rand = @import("utils.zig").Random;

pub const Vec3 = struct {
    e: [3]f64,

    pub fn new(x: f64, y: f64, z: f64) Vec3 {
        return Vec3 {
            .e = .{x, y, z}
        };
    }

    pub fn zero() Vec3 {
        return Vec3 {
            .e = .{ 
                0.0, 
                0.0, 
                0.0 
            },
        };
    }

    pub fn get_x(self: Vec3) f64 {
        return self.e[0];
    }

    pub fn get_y(self: Vec3) f64 {
        return self.e[1];
    }

    pub fn get_z(self: Vec3) f64 {
        return self.e[2];
    }

    pub inline fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .e = .{
                self.e[0] + other.e[0],
                self.e[1] + other.e[1],
                self.e[2] + other.e[2],
            },
        };
    }

    pub inline fn subtract(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .e = .{
                self.e[0] - other.e[0],
                self.e[1] - other.e[1],
                self.e[2] - other.e[2],
            },
        };
    }

    pub inline fn multiply(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .e = .{
                self.e[0] * other.e[0],
                self.e[1] * other.e[1],
                self.e[2] * other.e[2],
            },
        };
    }

    pub inline fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3.new(
            self.e[1] * other.e[2] - self.e[2] * other.e[1],
            self.e[2] * other.e[0] - self.e[0] * other.e[2],
            self.e[0] * other.e[1] - self.e[1] * other.e[0],
        );
    }

    pub inline fn scale(self: Vec3, t: f64) Vec3 {
        return Vec3 {
            .e = .{
                self.e[0] * t,
                self.e[1] * t,
                self.e[2] * t,
            },
        };
    }

    pub inline fn dot(self: Vec3, other: Vec3) f64 {
        return self.e[0] * other.e[0] + self.e[1] * other.e[1] + self.e[2] * other.e[2];
    }

    pub inline fn length_squared(self: Vec3) f64 {
        return self.dot(self);
    }

    pub inline fn length(self: Vec3) f64 {
        return @sqrt(self.length_squared());
    }

    // Same thing as unit vector
    pub inline fn normalize(self: Vec3) Vec3 {
        const len = self.length();
        if (len > 0.0) {
            return self.scale(1.0 / len);
        }

        return self;
    }

    pub inline fn random() Vec3 {
        return Vec3.new(rand.random_number(&rand.rng), rand.random_number(&rand.rng), rand.random_number(&rand.rng));
    }

    pub inline fn random_within_range(min: f64, max: f64) Vec3 {
        return Vec3.new(rand.random_range(&rand.rng, min, max), rand.random_range(&rand.rng, min, max), rand.random_range(&rand.rng, min, max));
    }

    pub inline fn random_normalize() Vec3 {
        while (true) {
            const p = Vec3.random_within_range(-1, 1);
            const lensq = p.length_squared();

            if (1e-160 < lensq and lensq <= 1) {
                return p.scale(1.0 / @sqrt(lensq));
            }
        }
    }

    pub inline fn random_on_hemisphere(normal: Vec3) Vec3 {
        const on_unit_sphere = Vec3.random_normalize();
        if (Vec3.dot(on_unit_sphere, normal) > 0.0) { // In same hemisphere as normal
            return on_unit_sphere;
        } else {
            return on_unit_sphere.scale(-1.0);
        }
    }

    pub inline fn near_zero(self: Vec3) bool {
        const s = 1e-8;

        return (@abs(self.e[0]) < s) and
                (@abs(self.e[1]) < s) and
                (@abs(self.e[2]) < s);
    }

    pub inline fn reflect(v: Vec3, n: Vec3) Vec3 {
        return v.subtract(n.scale(2 * v.dot(n)));
    }

    pub inline fn refract(uv: Vec3, n: Vec3, etai_over_etat: f64) Vec3 {
        const cos_theta = @min(uv.scale(-1.0).dot(n), 1.0);
        const r_out_prep: Vec3 = uv.add(n.scale(cos_theta)).scale(etai_over_etat);
        const r_out_parallel = n.scale(-@sqrt(@abs(1.0 - r_out_prep.length_squared())));

        return r_out_prep.add(r_out_parallel);
    }

    pub inline fn random_in_unit_disk() Vec3 {
        while (true) {
            const p = Vec3.new(rand.random_range(&rand.rng, -1, 1), rand.random_range(&rand.rng, -1, 1), 0);

            if (p.length_squared() < 1) {
                return p;
            }
        }
    }
};

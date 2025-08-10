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

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .e = .{
                self.e[0] + other.e[0],
                self.e[1] + other.e[1],
                self.e[2] + other.e[2],
            },
        };
    }

    pub fn subtract(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .e = .{
                self.e[0] - other.e[0],
                self.e[1] - other.e[1],
                self.e[2] - other.e[2],
            },
        };
    }

    pub fn scale(self: Vec3, t: f64) Vec3 {
        return Vec3 {
            .e = .{
                self.e[0] * t,
                self.e[1] * t,
                self.e[2] * t,
            },
        };
    }

    pub fn dot(self: Vec3, other: Vec3) f64 {
        return self.e[0] * other.e[0] + self.e[1] * other.e[1] + self.e[2] * other.e[2];
    }

    pub fn length_squared(self: Vec3) f64 {
        return self.dot(self);
    }

    pub fn length(self: Vec3) f64 {
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

    pub fn random() Vec3 {
        return Vec3.new(rand.random_number(&rand.rng), rand.random_number(&rand.rng), rand.random_number(&rand.rng));
    }

    pub fn random_within_range(min: f64, max: f64) Vec3 {
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
};

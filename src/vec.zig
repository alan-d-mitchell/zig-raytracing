const std = @import("std");

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

    pub fn normalize(self: Vec3) Vec3 {
        const len = self.length();
        if (len > 0.0) {
            return self.scale(1.0 / len);
        }
        
        return self;
    }
};

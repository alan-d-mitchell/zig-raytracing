const std = @import("std");
const vec3 = @import("vec.zig").Vec3;

pub const Ray = struct {
    orig: vec3,
    dir: vec3,

    pub fn new() Ray {
        return Ray {
            .orig = vec3 {
                .e = .{
                    0.0,
                    0.0,
                    0.0,
                }
            },

            .dir = vec3 {
                .e = .{
                    0.0,
                    0.0,
                    0.0,
                }
            },
        };
    }

    pub fn init(orig: vec3, dir: vec3) Ray {
        return Ray {
            .orig = orig,
            .dir = dir,
        };
    }

    pub fn origin(self: Ray) vec3 {
        return self.orig;
    }

    pub fn direction(self: Ray) vec3 {
        return self.dir;
    }

    pub fn at(self: Ray, t: f64) vec3 {
        return self.orig.add(self.dir.scale(t));
    }
};

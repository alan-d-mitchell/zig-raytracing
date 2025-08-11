const std = @import("std");

const vec3 = @import("vec.zig").Vec3;
const ray = @import("ray.zig").Ray;
const interval = @import("interval.zig").Interval;
const material = @import("material.zig").Material;

// struct to hold record of hit, very straightforward
pub const HitRecord = struct {
    p: vec3,
    normal: vec3,
    mat: *const material,
    t: f64,
    front_face: bool,

    pub fn init() HitRecord {
        return HitRecord {
            .p = vec3.zero(),
            .normal = vec3.zero(),
            .t = 0.0,
            .front_face = false,
            .mat = undefined,
        };
    }

    pub fn set_face_normal(self: *HitRecord, r: ray, outward_normal: vec3) void {
        self.front_face = r.direction().dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.scale(-1.0);
    }
};

// tagged union for future expansion of other shapes maybe
// allows to keep all the shapes under one variable but check the tag when hit is called
// only sphere for now
pub const Hittable = union(enum) {
    sphere: @import("sphere.zig").Sphere,

    pub fn hit(self: Hittable, r: ray, ray_t: interval, rec: *HitRecord) bool {
        switch (self) {
            .sphere => |sphere| return sphere.hit(r, ray_t, rec),
        }
    }
};

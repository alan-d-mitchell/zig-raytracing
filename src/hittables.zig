const std = @import("std");
const array_list = std.ArrayList;
const Allocator = std.mem.Allocator;

const vec3 = @import("vec.zig").Vec3;
const ray = @import("ray.zig").Ray;
const hit_record = @import("hit.zig").HitRecord;
const hittable = @import("hit.zig").Hittable;
const interval = @import("interval.zig").Interval;

pub const Hittables = struct {
    objects: array_list(hittable),
    allocator: Allocator,

    pub fn init(allocator: Allocator) Hittables {
        return Hittables {
            .objects = array_list(hittable).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn init_with_object(allocator: Allocator, object: hittable) !Hittables {
        var list = Hittables.init(allocator);
        try list.add(object);

        return list;
    }

    pub fn deinit(self: *Hittables) void {
        self.objects.deinit();
    }

    pub fn clear(self: *Hittables) void {
        self.objects.clearAndFree();
    }

    pub inline fn add(self: *Hittables, object: hittable) !void {
        try self.objects.append(object);
    }

    pub inline fn hit(self: Hittables, r: ray, ray_t: interval, rec: *hit_record) bool {
        var temp_rec = hit_record.init();
        var hit_anything = false;
        var closest_so_far = ray_t.max;

        for (self.objects.items) |object| {
            if (object.hit(r, interval.new(ray_t.min, closest_so_far), &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};



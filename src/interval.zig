const std = @import("std");

pub const Interval = struct {
    min: f64,
    max: f64,

    pub const empty = Interval {
        .min = std.math.inf(f64),
        .max = -std.math.inf(f64),
    };

    pub const universe = Interval {
        .min = -std.math.inf(f64),
        .max = std.math.inf(f64),
    };

    pub fn init() Interval {
        return Interval.empty;
    }

    pub fn new(min: f64, max: f64) Interval {
        return Interval {
            .min = min,
            .max = max,
        };
    }

    pub inline fn size(self: Interval) f64 {
        return self.max - self.min;
    }

    pub inline fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub inline fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }

    pub inline fn clamp(self: Interval, x: f64) f64 {
        if (x < self.min) return self.min;
        if (x > self.max) return self.max;

        return x;
    }
};

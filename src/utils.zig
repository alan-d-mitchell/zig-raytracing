const std = @import("std");

pub const Math = struct {
    pub inline fn degrees_to_radians(degrees: f64) f64 {
        return degrees * std.math.pi / 180.0;
    }
};

pub const Random = struct {
    pub var prng = std.Random.DefaultPrng.init(12345);
    pub var rng = prng.random();

    pub inline fn random_number(rand: *std.Random) f64 {
        return rand.float(f64);
    }

    pub inline fn random_range(rand: *std.Random, min: f64, max: f64) f64 {
        return min + (max - min) * random_number(rand);
    }
};

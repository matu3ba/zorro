const std = @import("std");
const builtin = @import("builtin");

// ctz - count trailing zeroes

inline fn ctzXi2(comptime T: type, a: T) i32 {
    @setRuntimeSafety(builtin.is_test);

    var x = switch (@bitSizeOf(T)) {
        32 => @bitCast(u32, a),
        64 => @bitCast(u64, a),
        128 => @bitCast(u128, a),
        else => unreachable,
    };
    var n: T = 1;
    // Number of trailing zeroes as binary search, from Hacker's Delight
    var mask: @TypeOf(x) = std.math.maxInt(@TypeOf(x));
    comptime var shift = @bitSizeOf(T);
    if (x == 0) return shift;
    inline while (shift > 1) {
        shift = shift >> 1;
        mask = mask >> shift;
        if ((x & mask) == 0) {
            n = n + shift;
            x = x >> shift;
        }
    }
    return @intCast(i32, n - @bitCast(T, (x & 1)));
}

pub fn __ctzsi2(a: i32) callconv(.C) i32 {
    return ctzXi2(i32, a);
}

pub fn __ctzdi2(a: i64) callconv(.C) i32 {
    return ctzXi2(i64, a);
}

pub fn __ctzti2(a: i128) callconv(.C) i32 {
    return ctzXi2(i128, a);
}

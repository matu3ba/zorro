const std = @import("std");
const builtin = @import("builtin");

// clz - count leading zeroes

inline fn clzXi2(comptime T: type, a: T) i32 {
    @setRuntimeSafety(builtin.is_test);

    var x = switch (@bitSizeOf(T)) {
        32 => @bitCast(u32, a),
        64 => @bitCast(u64, a),
        128 => @bitCast(u128, a),
        else => unreachable,
    };
    var n: T = @bitSizeOf(T);
    // Count first bit set using binary search, from Hacker's Delight
    var y: @TypeOf(x) = 0;
    comptime var shift: u8 = @bitSizeOf(T);
    inline while (shift > 0) {
        shift = shift >> 1;
        y = x >> shift;
        if (y != 0) {
            n = n - shift;
            x = y;
        }
    }
    return @intCast(i32, n - @bitCast(T, x));
}

pub fn __clzsi2(a: i32) callconv(.C) i32 {
    return clzXi2(i32, a);
}
pub fn __clzdi2(a: i64) callconv(.C) i32 {
    return clzXi2(i64, a);
}
pub fn __clzti2(a: i128) callconv(.C) i32 {
    return clzXi2(i128, a);
}

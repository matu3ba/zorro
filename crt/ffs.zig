const std = @import("std");
const builtin = @import("builtin");

// ffs - find first set
// ffs = (a == 0) => 0, (a != 0) => ctz + 1

inline fn ffsXi2(comptime T: type, a: T) i32 {
    @setRuntimeSafety(builtin.is_test);

    var x = switch (@bitSizeOf(T)) {
        32 => @bitCast(u32, a),
        64 => @bitCast(u64, a),
        128 => @bitCast(u128, a),
        else => unreachable,
    };
    var n: T = 1;
    var mask: @TypeOf(x) = std.math.maxInt(@TypeOf(x));
    comptime var shift = @bitSizeOf(T);
    // In contrast to ctz return 0
    if (x == 0) return 0;
    inline while (shift > 1) {
        shift = shift >> 1;
        mask = mask >> shift;
        if ((x & mask) == 0) {
            n = n + shift;
            x = x >> shift;
        }
    }
    // return ctz + 1
    return @intCast(i32, n - @bitCast(T, (x & 1))) + @as(i32, 1);
}

pub fn __ffssi2(a: i32) callconv(.C) i32 {
    return ffsXi2(i32, a);
}

pub fn __ffsdi2(a: i64) callconv(.C) i32 {
    return ffsXi2(i64, a);
}

pub fn __ffsti2(a: i128) callconv(.C) i32 {
    return ffsXi2(i128, a);
}

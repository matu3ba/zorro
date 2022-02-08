const builtin = @import("builtin");
const std = @import("std");
const math = std.math;
const testing = @import("std").testing;

// mulo - multiplication overflow
// * return a*%b.
// * return if a*b overflows => 1 else => 0
// - mulo_genericSmall as default
//   * optimized version with ca. 5% performance gain over muloXi4_genericSmall
// - mulo_genericFast for 2*bitsize <= usize
//   * optimized version with ca. 5% performance gain over muloXi4_genericFast

fn ReturnType(comptime ST: type) type {
    return struct {
        sum: ST,
        overflow: u8,
    };
}

fn mulo_genericSmall(comptime ST: type) fn (ST, ST) ReturnType(ST) {
    const RetType = ReturnType(ST);
    return struct {
        fn f(a: ST, b: ST) RetType {
            @setRuntimeSafety(builtin.is_test);
            var ret = RetType{
                .sum = undefined,
                .overflow = 0,
            };
            const min = math.minInt(ST);
            ret.sum = a *% b;
            if ((a < 0 and b == min) or (a != 0 and @divTrunc(ret.sum, a) != b))
                ret.overflow = 1;
            return ret;
        }
    }.f;
}

fn mulo_genericFast(comptime ST: type) fn (ST, ST) ReturnType(ST) {
    const RetType = ReturnType(ST);
    return struct {
        fn f(a: ST, b: ST) RetType {
            @setRuntimeSafety(builtin.is_test);
            var ret = RetType{
                .sum = undefined,
                .overflow = 0,
            };
            const EST = switch (ST) {
                i32 => i64,
                i64 => i128,
                i128 => i256,
                else => unreachable,
            };
            const min = math.minInt(ST);
            const max = math.maxInt(ST);
            var res: EST = @as(EST, a) * @as(EST, b);
            //invariant: -2^{bitwidth(EST)} < res < 2^{bitwidth(EST)-1}
            if (res < min or max < res)
                ret.overflow = 1;
            ret.sum = @truncate(ST, res);
            return ret;
        }
    }.f;
}

const mulosi = impl: {
    if (2 * @bitSizeOf(i32) <= @bitSizeOf(usize)) {
        break :impl mulo_genericFast(i32);
    } else {
        break :impl mulo_genericSmall(i32);
    }
};
const mulodi = impl: {
    if (2 * @bitSizeOf(i64) <= @bitSizeOf(usize)) {
        break :impl mulo_genericFast(i64);
    } else {
        break :impl mulo_genericSmall(i64);
    }
};
const muloti = impl: {
    if (2 * @bitSizeOf(i64) <= @bitSizeOf(usize)) {
        break :impl mulo_genericFast(i64);
    } else {
        break :impl mulo_genericSmall(i64);
    }
};
test "mulo" {
    const x: i32 = 0;
    const y: i32 = 0;
    const res = mulosi(x, y);
    try testing.expectEqual(@as(i32, 0), res.sum);
    try testing.expectEqual(@as(u8, 0), res.overflow);
}

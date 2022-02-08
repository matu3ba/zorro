const builtin = @import("builtin");
const testing = @import("std").testing;

// addo - add overflow
// * return a+%b.
// * return if a+b overflows => 1 else => 0
// - addo_generic as optimized version with ca. 5% performance gain
//   over addoXi4_generic

fn ReturnType(comptime ST: type) type {
    return struct {
        sum: ST,
        overflow: u8,
    };
}

fn addo_generic(comptime ST: type) fn (ST, ST) ReturnType(ST) {
    @setRuntimeSafety(builtin.is_test);
    const RetType = ReturnType(ST);
    return struct {
        fn f(a: ST, b: ST) RetType {
            @setRuntimeSafety(builtin.is_test);
            var ret = RetType{
                .sum = undefined,
                .overflow = 0,
            };
            ret.sum = a +% b;
            if (((ret.sum ^ a) & (ret.sum ^ b)) < 0)
                ret.overflow = 1;
            return ret;
        }
    }.f;
}

const addosi = addo_generic(i32);
const addodi = addo_generic(i64);
const addoti = addo_generic(i128);

test "addo" {
    const x: i32 = 0;
    const y: i32 = 0;
    const res = addosi(x, y);
    try testing.expectEqual(@as(i32, 0), res.sum);
    try testing.expectEqual(@as(u8, 0), res.overflow);
}

const builtin = @import("builtin");
const testing = @import("std").testing;

// subo - subtract overflow
// * return a-%b.
// * return if a-b overflows => 1 else => 0
// - subo_generic as optimized version with ca. 5% performance gain
//   over suboXi4_generic

fn ReturnType(comptime ST: type) type {
    return struct {
        sum: ST,
        overflow: u8,
    };
}

fn subo_generic(comptime ST: type) fn (ST, ST) ReturnType(ST) {
    @setRuntimeSafety(builtin.is_test);
    const RetType = ReturnType(ST);
    return struct {
        fn f(a: ST, b: ST) RetType {
            @setRuntimeSafety(builtin.is_test);
            var ret = RetType{
                .sum = undefined,
                .overflow = 0,
            };
            ret.sum = a -% b;
            if (((a ^ b) & (ret.sum ^ a)) < 0)
                ret.overflow = 1;
            return ret;
        }
    }.f;
}

const subosi = subo_generic(i32);
const subodi = subo_generic(i64);
const suboti = subo_generic(i128);

test "subo" {
    const x: i32 = 0;
    const y: i32 = 0;
    const res = subosi(x, y);
    try testing.expectEqual(@as(i32, 0), res.sum);
    try testing.expectEqual(@as(u8, 0), res.overflow);
}

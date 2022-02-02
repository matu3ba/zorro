const builtin = @import("builtin");

// neg - negate (the number)

// sfffffff = 2^31-1
// two's complement inverting bits and add 1 would result in -INT_MIN == 0
// => -INT_MIN = -2^31 forbidden

// * size optimized builds
// * machines that dont support carry operations

inline fn negXi2(comptime T: type, a: T) T {
    @setRuntimeSafety(builtin.is_test);
    return -a;
}

pub fn __negsi2(a: i32) callconv(.C) i32 {
    return negXi2(i32, a);
}

pub fn __negdi2(a: i64) callconv(.C) i64 {
    return negXi2(i64, a);
}

pub fn __negti2(a: i128) callconv(.C) i128 {
    return negXi2(i128, a);
}

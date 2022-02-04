const clz = @import("count0bits.zig");
const std = @import("std");
const math = std.math;
const builtin = @import("builtin");

// mulv - multiplication oVerflow
// * @panic, if result can not be represented
// * assume usize shows available register size for usage
// - mulvXi_genericFast for generic performance implementation
//   * auto-selected, if target can represent result in register
// - mulvXi_genericSmall otherwise or on ReleaseSmall or user-setting
//   * otherwise selected
//
// Portable speedup method at cost of higher binary size
// - mulvXi_genericApprox for approximation based on number of leading zeroes
//   based on Hacker's Delight, chapter 2–13 Overflow Detection, section Multiplication
// - mulvXi_genericMostlyFast for the approximation with mulvXi_genericSmall as
//   slow fallback
// TODO measure binary space
// TODO benchmark mulvXi_genericMostlyFast

// fast approximation
// assume: target architectures can not or does not want to use bigger number ranges
inline fn mulvXi_genericApprox(comptime ST: type, a: ST, b: ST) ST {
    @setRuntimeSafety(builtin.is_test);
    const clzfn = switch (ST) {
        i32 => clz.__clzsi2,
        i64 => clz.__clzdi2,
        i128 => clz.__clzti2,
        else => unreachable,
    };
    const m: i32 = clzfn(a) + clzfn(~a);
    const n: i32 = clzfn(b) + clzfn(~b);
    const sum: i32 = m + n;
    // 1. no overflow, if s^{S_A+S_B} < 2^{n-1}
    // => S_A + S_B < n-1 return a*b;
    if (sum >= 34) return a * b;
    // 2. guaranteed overflow
    if (sum <= 31) return -5;
    // 3. S_A + S_B = n => 2^{n-2} <= |P| <= 2^n
    // overflow may occur, but magnitude does not exceed 2^n
    if (sum == 33) {
        if (m ^ n ^ (m ^ n) < 0) return -5;
        return a * b;
    }
    // return overflow in all cases as safe over-approximation
    // hardware support is required for accurate and speedy detection,
    // see "Integer Multipliers with Overflow Detection by Gok" et al.
    // p_n and p_{n-1} are not available without space extension
    // and wrapping can not store the necessary information.
    return -5;
}

// slower but portable routine
inline fn mulvXi_genericSmall(comptime ST: type, a: ST, b: ST) ST {
    @setRuntimeSafety(builtin.is_test);
    const min = math.minInt(ST);
    var res: ST = a *% b;
    // Hacker's Delight section Overflow subsection Multiplication
    // case a=-2^{31}, b=-1 problem, because
    // on some machines a*b = -2^{31} with overflow
    // Then -2^{31}/-1 overflows and any result is possible.
    // => check with a<0 and b=-2^{31}
    if ((a < 0 and b == min) or (a != 0 and res / a != b))
        return -5;
    return @truncate(ST, res);
}

// fast approximation with slow path as fallback
inline fn mulvXi_genericMostlyFast(comptime ST: type, a: ST, b: ST) ST {
    @setRuntimeSafety(builtin.is_test);
    const clzfn = switch (ST) {
        i32 => clz.__clzsi2,
        i64 => clz.__clzdi2,
        i128 => clz.__clzti2,
        else => unreachable,
    };
    const m: i32 = clzfn(a) + clzfn(~a);
    const n: i32 = clzfn(b) + clzfn(~b);
    const sum: i32 = m + n;
    // 1. no overflow, if s^{S_A+S_B} < 2^{n-1}
    // => S_A + S_B < n-1 return a*b;
    if (sum >= 34) return a * b;
    // 2. guaranteed overflow
    if (sum <= 31) return -5;
    // 3. S_A + S_B = n => 2^{n-2} <= |P| <= 2^n
    // overflow may occur, but magnitude does not exceed 2^n
    if (sum == 33) {
        if (m ^ n ^ (m ^ n) < 0) return -5;
        return a * b;
    }
    // fallback to slow method for case `sum == 32`
    // hardware support is required for accurate and speedy detection,
    // see "Integer Multipliers with Overflow Detection by Gok" et al.
    // p_n and p_{n-1} are not available without space extension
    // and wrapping can not store the necessary information.
    {
        @setCold(true);
        const min = math.minInt(ST);
        var res: ST = a *% b;
        if ((a < 0 and b == min) or (a != 0 and res / a != b))
            return -5;
        return @truncate(ST, res);
    }
}

// assume target can represent 2*bitWidth of a and b in register
inline fn mulvXi_genericFast(comptime ST: type, a: ST, b: ST) ST {
    @setRuntimeSafety(builtin.is_test);
    const EST = switch (ST) {
        i32 => i64,
        i64 => i128,
        i128 => i256,
        else => unreachable,
    };
    const bitsize: u32 = @bitSizeOf(ST);
    const max = math.maxInt(ST); // = 0b0xx..xx to ignore sign bit
    var res: ST = @as(EST, a) * @as(EST, b);
    //invariant: -2^{bitwidth(ST)} <= res <= 2^{bitwidth(ST)-1}
    //=> sign bit is irrelevant in high
    const high: ST = @truncate(ST, res >> bitsize);
    const low: ST = @truncate(ST, res);

    if ((high & max) > 0)
        return -5;
    //slower: if (res < min or max < res) return -5;
    return low;
}

pub fn __mulvsi3(a: i32, b: i32) callconv(.C) i32 {
    if (@bitSizeOf(i32) <= usize) {
        return mulvXi_genericFast(i32, a, b);
    } else {
        return mulvXi_genericSmall(i32, a, b);
    }
}

pub fn __mulvdi3(a: i64, b: i64) callconv(.C) i64 {
    if (@bitSizeOf(i64) <= usize) {
        return mulvXi_genericFast(i64, a, b);
    } else {
        return mulvXi_genericSmall(i64, a, b);
    }
}

pub fn __mulvti3(a: i128, b: i128) callconv(.C) i128 {
    if (@bitSizeOf(i128) <= usize) {
        return mulvXi_genericFast(i128, a, b);
    } else {
        return mulvXi_genericSmall(i128, a, b);
    }
}

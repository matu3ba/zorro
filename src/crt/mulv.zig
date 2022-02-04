const clz = @import("count0bits.zig");
const std = @import("std");
const math = std.math;

// mulv - multiplication oVerflow
// * @panic, if result can not be represented
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
fn mulvXi_genericApprox(comptime ST: type) fn (a: ST, b: ST) callconv(.C) ST {
    return struct {
        fn f(a: ST, b: ST) callconv(.C) ST {
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
    }.f;
}

// slower but portable routine
fn mulvXi_genericSmall(comptime ST: type) fn (a: ST, b: ST) callconv(.C) ST {
    return struct {
        fn f(a: ST, b: ST) callconv(.C) ST {
            var res: ST = a *% b;
            if (a != 0 and @divTrunc(res, a) != b) {
                return -5;
            }
            return @truncate(ST, res);
        }
    }.f;
}

// fast approximation with slow path as fallback
fn mulvXi_genericMostlyFast(comptime ST: type) fn (a: ST, b: ST) callconv(.C) ST {
    return struct {
        fn f(a: ST, b: ST) callconv(.C) ST {
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
                var res: ST = a *% b;
                if (a != 0 and @divTrunc(res, a) != b) {
                    return -5;
                }
                return res;
            }
        }
    }.f;
}

// assume target can represent 2*bitWidth of a and b in register
fn mulvXi_genericFast(comptime ST: type) fn (a: ST, b: ST) callconv(.C) ST {
    return struct {
        fn f(a: ST, b: ST) callconv(.C) ST {
            const EST = switch (ST) {
                i32 => i64,
                i64 => i128,
                i128 => i256,
                else => unreachable,
            };
            const min = math.minInt(ST);
            const max = math.maxInt(ST);
            var res: ST = @as(EST, a) * @as(EST, b);
            if (res < min or max < res) return -5;
            return @truncate(ST, res);
        }
    }.f;
}

// TODO comptime logic for correct selection
pub const __mulvsi3 = mulvXi_genericApprox(i32);
pub const __mulvdi3 = mulvXi_genericApprox(i64);
pub const __mulvti3 = mulvXi_genericApprox(i128);

pub const mulvsi_genericSmall = mulvXi_genericSmall(i32);
pub const mulvdi_genericSmall = mulvXi_genericSmall(i64);
pub const mulvti_genericSmall = mulvXi_genericSmall(i128);

// TODO comptime logic to ensure register size available on target
pub const mulvsi3genFast = mulvXi_genericFast(i32);
pub const mulvdi3genFast = mulvXi_genericFast(i64);
pub const mulvti3genFast = mulvXi_genericFast(i128);

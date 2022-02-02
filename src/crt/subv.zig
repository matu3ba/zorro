// subv - subtract oVerflow
// * @panic, if result can not be represented
// - subvXi4_generic for unoptimized version

fn subvXi_generic(comptime ST: type) fn (a: ST, b: ST) callconv(.C) ST {
    return struct {
        fn f(a: ST, b: ST) callconv(.C) i32 {
            var sum: ST = a -% b;
            // Hackers Delight: section Overflow Detection, subsection Signed Add/Subtract
            // Let sum = a -% b == a - b - carry == wraparound subtraction.
            // Overflow in a-b-carry occurs, iff a and b have opposite signs
            // and the sign of a-b-carry is opposite of a (or equivalently same as b).
            // Faster routine: res = (a ^ b) & (sum ^ a)
            // Slower routine: res = (sum^a) & ~(sum^b)
            // Oerflow occured, iff (res < 0)
            if (((a ^ b) & (sum ^ a)) < 0)
                return -5;
            return sum;
        }
    }.f;
}
pub const __subvsi3 = subvXi_generic(i32);
pub const __subvdi3 = subvXi_generic(i64);
pub const __subvti3 = subvXi_generic(i128);

// addv - add oVerflow
// * @panic, if result can not be represented

fn addvXi_generic(comptime ST: type) fn (a: ST, b: ST) callconv(.C) ST {
    return struct {
        fn f(a: ST, b: ST) callconv(.C) ST {
            var sum: ST = a +% b;
            // Hackers Delight: section Overflow Detection, subsection Signed Add/Subtract
            // Let sum = a +% b == a + b + carry == wraparound addition.
            // Overflow in a+b+carry occurs, iff a and b have opposite signs
            // and the sign of a+b+carry is the same as a (or equivalently b).
            // Slower routine: res = ~(a ^ b) & ((sum ^ a)
            // Faster routine: res = (sum ^ a) & (sum ^ b)
            // Oerflow occured, iff (res < 0)
            if (((sum ^ a) & (sum ^ b)) < 0)
                return -5;
            return sum;
        }
    }.f;
}
pub const __addvsi3 = addvXi_generic(i32);
pub const __addvdi3 = addvXi_generic(i64);
pub const __addvti3 = addvXi_generic(i128);

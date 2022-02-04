#include "header.h"

void proof_mulv() {
    z3::context ctx;
    z3::expr a = ctx.bv_const("a", 64);
    z3::expr b = ctx.bv_const("b", 64);
    z3::expr res = ctx.bv_const("res", 64);
    z3::expr i64max = ctx.bv_const("i64max", 64);
    z3::expr i64min = ctx.bv_const("i64max", 64);
    z3::expr mulres = ctx.bv_const("mulres", 64);
    int64_t maxi64 = 2147483647;
    int64_t mini64 = -2147483648;
    i64min = ctx.bv_val(mini64, 64);
    i64max = ctx.bv_val(maxi64, 64);

    z3::expr_vector forallvec(ctx);
    forallvec.push_back(a);
    forallvec.push_back(b);
    forallvec.push_back(res);

    z3::expr rhs = (i64min <= mulres && mulres <= i64max);

    //z3::expr tmp =
    //(
    //  1 <= a && a <= 2147483647 && 1 <= b && b <= 2147483647
    //  && mulres == a*b
    //  && res == z3::smod(mulres,i64max)
    //  && res / a == b
    //);
    //z3::expr cond = (i64min <= mulres && mulres <= i64max);
    //z3::expr implies = z3::implies(tmp, cond);

    {
        z3::expr lhs =
        (
          i64min <= a && a <= -1 && i64min <= b && b <= -1
          && mulres == a*b
          && res == z3::smod(mulres,i64min)
          && res / a == b
        );
        proveImplication(ctx, forallvec, lhs, rhs);
    }

    //z3::expr forallexpr = z3::exists(forallvec, tmp);
    //z3::solver solver(ctx);
    //solver.add(forallexpr);
    //z3::check_result proofres = solver.check();
    //assert(proofres == z3::check_result::sat);
    //std::cout << "sat\n";
    //z3::model m = solver.get_model();
    //std::cout << "model satisfiable:\n" << m << "\n";
}

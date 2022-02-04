#ifndef HEADER_H
#define HEADER_H
#include <z3++.h>
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_RESET   "\x1b[0m"
#include <stdio.h>
#include <stdlib.h>

void proof_mulv();

inline void proveImplication(z3::context &ctx, z3::expr_vector &forallvec, z3::expr &lhs, z3::expr &rhs)
{
    z3::expr implies = z3::implies(lhs, rhs);
    z3::expr forallexpr = z3::forall(forallvec, implies);
    z3::solver solver(ctx);
    solver.add(forallexpr);
    z3::check_result proofres = solver.check();
    if (proofres != z3::check_result::sat)
    {
        printf(ANSI_COLOR_RED "Proof failed" ANSI_COLOR_RESET "\n");
        assert(false); // for stack traces
        exit(1);
    }
}

inline void printSuccess(const char* name_proof)
{
    printf(ANSI_COLOR_GREEN "proved ");
    printf("%s", name_proof);
    printf(ANSI_COLOR_RESET "\n");
}

// simpler usage
//z3::model m = solver.get_model();
//std::cout << "counter-example:\n";
//std::cout << "model satisfiable:\n" << m << "\n";

#endif // HEADER_H

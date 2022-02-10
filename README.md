# zorro
Integer bit hacks and architecture-independent compiler_rt in Zig optimized for
2s complement and verified in Z3

Code has 0BSD license, proofs have MIT license.
The license of Z3 is inside the cloned folder `z3`.

## Dependencies
To reduce maintenance cmake and ninja with python are required and a zig from master branch
to use zig with integrated libclang as c and c++ compiler.
Zig from master branch is available [here for download](https://ziglang.org/download/),
can be [bootstrapped here](https://github.com/ziglang/zig-bootstrap) or build with the
[instructions from the wiki](https://github.com/ziglang/zig/wiki/Building-Zig-From-Source).

WIP.

## Structure

Folder prefixed with `p` for corresponding proofs.

- `crt` for `compiler_rt`

## Building

Run these commands, unless there is an error.
```sh
git clone --depth=1 https://github.com/Z3Prover/z3 z3
cd z3
mkdir -p build
cd build
CC='zig cc' CXX='zig c++' cmake .. -GNinja
ninja          # build z3 with libclang integrated in zig
cd ..

zig build      # build binary
# workaround of https://github.com/ziglang/zig/issues/10785
cd zig-out
./bin/runProofs
cd ..
```

## Todos

- [x] building z3
- [x] building and linking c++ programs with z3 proofs
- [ ] fix `zig build` to run the proofs (https://github.com/ziglang/zig/issues/10785)
- [ ] architecture-independent compiler_rt
- [ ] verify compiler_rt
- [ ] list of all integer bit-hacks (0BSD)
- [ ] implement common bit-hacks (0BSD)
- [ ] verify common bit-hacks (MIT)
- [ ] link or explain common theories and techniques (check license that arxiv uses)

experiments

- [ ] z3 c bindings used in zig
- [ ] extract arithmetic from zig compiler of a fn block as stmlib2 string
- [ ] generate edge cases for testing from z3 proofs

## Ressources

- older releases (<80) of LLVM which use MIT license.
- https://bits.stephan-brumme.com/
- http://aggregate.org/MAGIC/
- http://graphics.stanford.edu/~seander/bithacks.html
- Hacker's Delight for most common things, code https://github.com/hcs0/Hackers-Delight
- https://www.chessprogramming.org/Bit-Twiddling
- https://github.com/keon/awesome-bits
- https://github.com/golang/go/issues/18616
- https://www.fefe.de/intof.html

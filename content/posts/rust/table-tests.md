+++
title = "Table Driven Tests"
date = "2019-10-06"
author = "Gregory Hill"
tags = [
    "rust",
]
+++

One of my favorite ways to write tests in Go is with a table driven test. If you are unfamiliar
with the concept check out the [excellent Dave Cheney post](https://dave.cheney.net/2013/06/09/writing-table-driven-tests-in-go).
If you need to unit test a component under a multitude of edge cases, then this is good technique to adopt.
Anyway, I'm learning Rust in my spare time so I thought I'd best give it a go. Hopefully this will suffice, but if you
think it could be improved please hit me up on [twitter](https://twitter.com/gregorydhill).

Following in Dave's footsteps, let's implement a recursive function to calculate the 
[fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_number):

```rust
fn fib(n: i64) -> i64 {
    if n < 2 {
            return n
    }
    return fib(n-1) + fib(n-2)
}
```

For the structure itself we'll need to define a `struct` which details our required
input(s) - in this case `n` - and our expected result (`e`). We can then iterate over
an array of these test cases, using the macro `assert_eq!` to ensure the computed
result matches.

```rust
#[test]
fn table() {
    struct Pair {
        n: i64,
        e: i64,
    }

    let fib_tests: [Pair; 7] = [
        Pair {
            n: 1,
            e: 1, 
        },
        Pair {
            n: 2,
            e: 1, 
        },
        Pair {
            n: 3,
            e: 2, 
        },
        Pair {
            n: 4,
            e: 3, 
        },
        Pair {
            n: 5,
            e: 5, 
        },
        Pair {
            n: 6,
            e: 8, 
        },
        Pair {
            n: 7,
            e: 13, 
        },
    ];

    for test in fib_tests.iter() {
        assert_eq!(test.e, fib(test.n))
    }
}
```

See the [docs](https://doc.rust-lang.org/rust-by-example/testing/unit_testing.html) for 
more information on unit testing in Rust!
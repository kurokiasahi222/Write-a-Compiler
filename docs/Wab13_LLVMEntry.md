# Wab 13 - Function Arguments

Here's a bit of a programming puzzler.  Consider the following program:

```
func add1(n) {
     n = n + 1;
     return n;
}

var a = 100;
print add1(a);    // Prints "101"
print a;          // Prints ????
```

What is the expected output of the `print` on the last line and why
would you care?

## Function Argument Passing

When you call a function, input arguments are provided.  However, what
is the nature of these arguments?  Are they copies of some value?  If
so, are the arguments stored in memory someplace? If so, where? Or are
the arguments a reference to an already existing memory location?  For
example, does the argument `n` in this example refer to the same
memory location of the variable `a`?

Depending on the answer, the last `print` might produce an output of
`100` or `101`. It's the kind of thing that might start a bigger
question about programming language design.

For our purposes, Wab passes function arguments by value--meaning that
they are a copy of the original input.  Moreover, in order to support
mutation, this copy needs to have a reserved memory location where
updated values can be stored without affecting values located elsewhere.

## Function Entry Blocks

To address this technical issue concerning function arguments, we have
to help LLVM by adding an "entry" block to each function that
allocates variables and stores the values of the function arguments.
Without this, subsequent `load` and `store` arguments don't work
correctly.

To illustrate, consider the following Wab function:

```
def add(x, y):
    var r = x + y;
    return r;
```

The LLVM code for this function looks like the following:

```
func add(x, y) {
    L1:
        LLVM(%r = alloca i32)
        LLVM(%.1 = load i32, i32* %x)    // Where is %x?
        LLVM(%.2 = load i32, i32* %y)    // Where is %y?
        LLVM(%.3 = add i32 %.1, %.2)
        LLVM(store i32 %.3, i32* %r)
        LLVM(%.4 = load i32, i32* %r)
        LLVM(ret i32 %.4)
}
```

The basic problem is that the `%x` and `%y` variables need a memory
allocation.   To fix this, we're going to add a new block to the function
to make it look like this:

```
func add(.arg_x, .arg_y) {
    entry:
        LLVM(%x = alloca i32)            // Allocate %x
        LLVM(store i32 %.arg_x, i32* %x) // Copy the x argument
        LLVM(%y = alloca i32)            // Allocate %y
        LLVM(store i32 %.arg_y, i32* %y) // Copy the y argument 
        LLVM(br label %L1)

    L1:
        LLVM(%r = alloca i32)
        LLVM(%.1 = load i32, i32* %x)    // Where is %x?
        LLVM(%.2 = load i32, i32* %y)    // Where is %y?
        LLVM(%.3 = add i32 %.1, %.2)
        LLVM(store i32 %.3, i32* %r)
        LLVM(%.4 = load i32, i32* %r)
        LLVM(ret i32 %.4)
}
```

Additionally, the function arguments have been renamed to
have names that are distinct from the function parameter
variables (e.g., `.arg_x` instead of `x`).

## Your Task

Your task is to write a compiler pass that adds an appropriate
"entry" block to every function for storing the input arguments.
This pass needs to perform three tasks for each function:

1. Function parameters should be renamed in the function definition.
   If you have an parameter called `x`, rename it to `.arg_x` (yes, with
   the leading `.`) in the `Function` definition.

2. Create an "entry" block.  For each function parameter, generate LLVM
   instructions that allocate memory and copy the input argument like this:

```
        LLVM(%x = alloca i32)
        LLVM(store i32 %.arg_x, i32* %x)
```

3. Link the entry block to the first block of the function by adding
   a `br label %Ln` instruction at the end where `Ln` refers to
   the label of the first block.

## Hints

Put this pass in a file such as `llvmentry.py`.   This pass should not
involve a lot of code.  You should be able to do it with a single
`for-loop` that scans the program for all function definitions and
replaces each definition with a modified version that has the entry
block added to it.

## Big Picture

In earlier stages of the compiler, we were mostly concerned about the
direct translation of Wab code to machine instructions in the abstract.  This project
is not so much about that, but more concerned about plumbing
and low-level systems details. In order for functions to work correctly, they
have to integrate with the surrounding environment.  This often involves
details of memory management, operating systems, I/O, synchronization
and other matters.   In general, the lower-level you go, the more you'll
have to worry about this.

## Compiler Design Discussion

One hacky part of this project concerns a bit of renaming.  As
described, a function argument such as `x` had to be renamed to
`.arg_x`.  The purpose of this renaming was to separate function
arguments as handled by LLVM from the memory storage of function
arguments as used in our generated code.   One might ask if
there is a "less hacky" way to handle all of this.


















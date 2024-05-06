# Wab 15 - Runtime

The primary focus of our compiler has been on the conversion of code
to machine instructions for carrying out some kind of computation.
However, certain features of a programming language are not so much
about computation, but about other issues such as I/O, memory management,
concurrency, etc.

These features are not related to instructions provided by a CPU, but to
services provided by an operating system (i.e., Windows, MacOS, Linux, etc.).
Because of this, you have to take a different approach to implementation.

In this project, we will provide the implementation of printing so that
the following Wab statement can actually work:

```
print 42;
```

## Implementing a Runtime Library

System-level features are often provided by programming libraries.  For example,
the C standard library typically provides functions for interacting with
the operating system.

To use this library, we can implement our own functions in C.  For example,
here is an implementation of printing.

```
/* runtime.c */

#include <stdio.h>

int _print_int(int value) {
    printf("Out: %i\n", value);
    return 0;
}
```

Note that the name of this function (`_print_int`) matches the name of a
function we declared and used in our LLVM code.   For example,
the "instruction" for printing in LLVM was written as follows:

```
call i32 (i32) @_print_int({value})
```

Create your own `runtime.c` file and copy the above code into it.

## Compiling with the Runtime

To use the runtime library, include it in final compilation step with `clang`
like this:

```
shell % clang out.ll runtime.c -o out.exe
```

If this works, you should end up with a final executable `out.exe` that you
can run:

```
shell % ./out.exe
(output of your program here)
shell %
```

Congratulations, you've managed to make a runable program!   Try compiling
some of your other test programs and running them to make sure they work.

## Loose Ends

By now, you should have some code that can parse an input program and generate
LLVM code for it.  You also have the necessary steps needed to compile the resulting
program.   However, it all might be a bit messy.

As a final step, consider cleaning up your compiler a bit so that it can
take an input program and produce a working executable as a final output.
As part of this process, you can have your compiler automatically call `clang`
in the background (i.e., you can use something like `os.system(...)` to execute
it as a system command).

You might also add a few debugging features so that you can see the results of
all of the various compiler passes.

Stare in amazement.  Thus concludes the "Wab" part of the project.









# Wab 14 - LLVM Formatting

The final compiler pass is to properly format your LLVM program into a textual form that can
be compiled by `clang`.   So, in some sense, the end of the compiler
is back to where we started--code formatting.

## Overview

At this stage, you've managed to convert Wab programs into a form that
looks something like this when formatted:

```
func add(.arg_x, .arg_y) {
    entry:
        LLVM(%x = alloca i32)
        LLVM(store i32 %.arg_x, i32* %x)
        LLVM(%y = alloca i32)
        LLVM(store i32 %.arg_y, i32* %y)
        LLVM(br label %L8)

    L8:
        LLVM(%r = alloca i32)
        LLVM(%.14 = load i32, i32* %x)
        LLVM(%.15 = load i32, i32* %y)
        LLVM(%.16 = add i32 %.14, %.15)
        LLVM(store i32 %.16, i32* %r)
        LLVM(%.17 = load i32, i32* %r)
        LLVM(ret i32 %.17)
}

global result;
func main() {
    entry:
        LLVM(br label %L9)
    
    L9:
        LLVM(%.18 = call i32 (i32,i32) @add(i32 3,i32 4))
        LLVM(store i32 %.18, i32* @result)
        LLVM(%.19 = load i32, i32* @result)
        LLVM(call i32 (i32) @_print_int(i32 %.19))
        LLVM(ret i32 0)
}
```

The above output is being created by some variant of the code formatter
created all the way back in Project 1!

Basically, we need to write a new formatter that outputs the code
in the following text format:

```
declare i32 @_print_int(i32)

define i32 @add(i32 %.arg_x, i32 %.arg_y) {
entry:
    %x = alloca i32
    store i32 %.arg_x, i32* %x
    %y = alloca i32
    store i32 %.arg_y, i32* %y
    br label %L8
L8:
    %r = alloca i32
    %.14 = load i32, i32* %x
    %.15 = load i32, i32* %y
    %.16 = add i32 %.14, %.15
    store i32 %.16, i32* %r
    %.17 = load i32, i32* %r
    ret i32 %.17
    ret i32 0
}

@result = global i32 0

define i32 @main() {
entry:
    br label %L9
L9:
    %.18 = call i32 (i32,i32) @add(i32 3,i32 4)
    store i32 %.18, i32* @result
    %.19 = load i32, i32* @result
    call i32 (i32) @_print_int(i32 %.19)
    ret i32 0
    ret i32 0
}
```

There's not much to this formatting.  Here are the basic rules
of what's happening:

1. Convert every `LLVM(op)` instance into `op` where there's
   maybe a bit of indentation and a newline added to it.

2. Every `BLOCK` instance should print the block label on its
   own line (e.g., `Ln:`) followed by all of the instructions
   contained in the block.

3. Every `global x` declaration turns into code like `@x = global i32 0`.

4. Every function of the form `func f(a, b) { body }` turns into 
   `define i32 @f(i32 %a, i32 %b) { body }`.

5. You need to add a short preamble to the top of the file to
   declare the `_print_int()` function used for printing.  See the
   above example for the prototype.

## Your Task

Create a file `llvmformat.py` that contains a function for creating
the final LLVM output.  For example:

```
# llvmformat.py

def format_llvm(program : Program) -> str:
    ...
```

This function will create output according to the above rules.

Add this function as the final step of all of the other compiler
passes.   Modify your code to write a file `out.ll` that contains
the LLVM output.

Once you have done this, you can try compiling the final output
through clang like this:

```
shell % python3 compile.py tests/fact.wb
Wrote out.ll
shell % clang -c out.ll
warning: overriding the module target triple with x86_64-apple-macosx10.15.4
      [-Woverride-module]
1 warning generated.
shell %
```

If it works, you should get no error messages and an `out.o`
file should be created.

Sadly, we still don't have enough to make a runable program.
Try removing the `-c` option and compile your code like this:

```
shell % clang out.ll
clang out.ll
warning: overriding the module target triple with x86_64-apple-macosx10.15.4
      [-Woverride-module]
1 warning generated.
Undefined symbols for architecture x86_64:
  "__print_int", referenced from:
      _main in out-034b3a.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
shell %
```

Arg!  We still don't know how to print.  We'll address this in the next project.

## Hints

We've done a LOT of work to get to this point.  When you finally try
to compile the final LLVM code, you may find that there are a number
of errors due to typos or some other forgotten details.  If this is the
case, make sure you fully read the error message produced by `clang`
and then try to work backwards to find the source.  In many cases,
errors are the result of something extremely small like forgetting a
comma or not producing a variable name correctly.

Please post questions to the chat/discussion if you are running into
weird LLVM issues.   I've seen most problems before and may be able to
provide a quick answer.

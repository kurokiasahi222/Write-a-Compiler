# LLVM Code Generation Tutorial

This is a tutorial on how to write assembly language programs by hand
in LLVM.  For this tutorial, you will need to have the clang C/C++
compiler installed.  Clang is the default C compiler on Mac systems.
It can also be installed for Linux and Windows.   More information
can be found at [llvm.org](https://llvm.org).

## The Compiler Backend

Consider the following C program that prints the value of the first ten factorials:

```c
/* fact.c */

#include <stdio.h>

int fact(int n) {
  int result = 1;
  while (n > 0) {
    result = result * n;
    n = n - 1;
  }
  return result;
}

int main() {
  for (int x = 1; x < 10; x++) {
    printf("%i\n", fact(x));
  }
}
```

The output of a compiler is assembly code--a human readable version of
low-level machine code.  Here is an example that shows how to generate
and view the assembly for the above program using the C compiler. Use
the `clang -S fact.c` command to generate the assembly. 

```
shell % clang -S fact.c      # Creates fact.s
shell % cat fact.s
	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 10, 15	sdk_version 10, 15, 4
	.globl	_fact                   ## -- Begin function fact
	.p2align	4, 0x90
_fact:                                  ## @fact
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%edi, -4(%rbp)
	movl	$1, -8(%rbp)
LBB0_1:                                 ## =>This Inner Loop Header: Depth=1
	cmpl	$0, -4(%rbp)
	jle	LBB0_3
## %bb.2:                               ##   in Loop: Header=BB0_1 Depth=1
	movl	-8(%rbp), %eax
	imull	-4(%rbp), %eax
	movl	%eax, -8(%rbp)
	movl	-4(%rbp), %eax
	subl	$1, %eax
	movl	%eax, -4(%rbp)
	jmp	LBB0_1
LBB0_3:
	movl	-8(%rbp), %eax
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function
	.globl	_main                   ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$16, %rsp
	movl	$0, -4(%rbp)
	movl	$1, -8(%rbp)
LBB1_1:                                 ## =>This Inner Loop Header: Depth=1
	cmpl	$10, -8(%rbp)
	jge	LBB1_4
## %bb.2:                               ##   in Loop: Header=BB1_1 Depth=1
	movl	-8(%rbp), %edi
	callq	_fact
	leaq	L_.str(%rip), %rdi
	movl	%eax, %esi
	movb	$0, %al
	callq	_printf
## %bb.3:                               ##   in Loop: Header=BB1_1 Depth=1
	movl	-8(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -8(%rbp)
	jmp	LBB1_1
LBB1_4:
	movl	-4(%rbp), %eax
	addq	$16, %rsp
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function
	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"%i\n"
```

Assembly code consists mainly of instructions (one per line) and jump
labels that are used by various branch, call, and goto instructions.
The exact set of instructions depends on the CPU architecture of your
machine and may differ from what's shown here.  Assembly code is not
meant to be portable--or anything beyond "barely readable" for that
matter.

To see assembly code for different CPU architectures, I recommend
using [Compiler Explorer](https://godbolt.org).  You can paste in
the above C code and select different processor targets.

Conversion of assembly code to machine code is performed by an
assembler--a separate program. An assembler is kind of like a
compiler except a lot more primitive. Essentially, it reads an
assembly text-file line-by-line and directly translates each
instruction into its corresponding binary encoding for the machine.

Here's how to assemble the above code into an object file that
contains the actual binary-encoded machine code:

```
shell % as fact.s -o fact.o     # Creates a file fact.o
```

The resulting `fact.o` file is not a human readable text file. However, it's
still not runnable either.  To make a runnable program, you need to
run the linker which is a separate program (`ld`) that resolves all of the
symbolic names, jump labels, and library calls (e.g., the `printf()`
function used in the example).  Direct invocation of the linker is likely
to be a frustrating experience that leads to failure.   However, if
you want to see what happens, you can run `clang` in verbose mode.
Try typing the following:

```
shell % clang --verbose fact.c
... a lot of output follows ...
```

The very last step of compilation shown in the verbose output will be the linking step.

## The Problem

You might look at all of these steps and think "wow, what a mess!"
This is a correct interpretation.  As a general rule, compiler output
is cryptic, low-level, non-portable, and tool-heavy. If only there was
an easier way.

## Enter LLVM

LLVM is a generic assembly language that's designed to simplify many
of the problems associated with generating machine code.  Unlike
normal assembly code, LLVM is meant to be platform-neutral and
portable.  However, LLVM is NOT something that is natively understood
by real hardware. To make a runable program, LLVM must first be
translated into the appropriate assembly code for the processor on
your machine.  That code would then be translated into machine code.

To see an LLVM version of the `fact.c` program, try typing the following:

```
shell % clang -emit-llvm -S fact.c
```

Now, look at the generated `fact.ll` file.

LLVM is an example of something known as "Intermediate Representation"
or IR code.  IR code is low-level like machine code, but offers a
number of abstractions to make code generation easier. For example,
you won't have to worry about details related to CPU registers or
figuring out what CPU-specific instructions to use for obscure
corner cases. LLVM will take care of those details for you.

The remainder of this tutorial will have you write some simple
programs directly in LLVM assembly.  You will compile and link these
programs with additional code written in C.

## Hello LLVM

Our first task is to make sure that all of the tooling works.
Start by creating a C program that looks like this:

```c
/* main.c */
#include <stdio.h>

extern int hello();

int main() {
    printf("hello() returned %i\n", hello());
    return 0;
}
```

This C program calls out to an external function called `hello` and
prints its result.  Try compiling this program with `clang`.  You should
get an error:

```
shell % clang main.c
Undefined symbols for architecture x86_64:
  "_hello", referenced from:
      _main in main-d5c22d.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

First, a critical observation.  Assembly code (including LLVM) is so low-level
that there aren't even any features for printing.   Therefore, if you want to
do something like that, you've either got to write it completely from scratch (in assembly)
or use an existing library.  We're choosing the latter.  The purpose of
`main.c` is to use C for producing output.  We're now going to write
the `hello()` function in assembly.

Create a new file called `hello.ll` that contains the following code:

```llvm
; hello.ll      (a comment)

define i32 @hello()
{
   ret i32 37
}
```

This program defines a global function called `hello()` that returns a 32-bit
integer value 37.   Try compiling and running:

```
shell % clang main.c hello.ll -o hello.exe
shell % ./hello.exe
hello() returned 37
```

Congratulations.  You just built your first LLVM program.  Note: the `clang` compiler,
although intended for C/C++, understands LLVM assembly as input. Clang is based
on all of the LLVM tooling so it simply knows how to deal with it.

If you want to see the actual machine instructions generated by LLVM, use `clang -S hello.ll`.
This will create a file `hello.s` with platform-native machine instructions.

## Mathematical calculations

Let's modify the `hello()` function to compute the value of `2 + 3*4`.
Make it look like this:

```llvm
; hello.ll
define i32 @hello()
{
    %1 = mul i32 3, 4
    %2 = add i32 2, %1
    ret i32 %2
}
```

Rebuild your program and make sure it produces this output:

```
shell % clang main.c hello.ll -o hello.exe
shell % ./hello.exe
hello() returned 14
```

A few critical things.  LLVM is conceptually based around something known as
"three-address code."  This is a convention where all mathematical operations
are structured as operations that take two inputs and produce an output.  This
closely mimics the behavior of how actual CPUs work.

The result of all operations must be stored in local temporary
variables.  In LLVM, these variables are prefixed by a `%`.  The
variables `%1` and `%2` in the example are temporaries.

All operations have an associated type.  In this example, we are
performing a 32-bit multiply and a 32-bit sum.  This is indicated by
the operations `mul i32` and `add i32` respectively.  Similarly, the
`ret i32` instruction indicates the return of a 32-bit integer.

Temporary variables may never be reused or reassigned. This is
something known as single static assignment (SSA).  For example,
modify the code as follows and see what happens:

```llvm
; hello.ll
define i32 @hello()
{
    %1 = mul i32 3, 4
    %1 = add i32 2, %1       ; Should produce an error
    ret i32 %1
}
```

The inability to reassign a variable leads to some "interesting" challenges
later on, but we'll worry about that later.

Think of the temporary variables as CPU registers.  Each time you
compute something, you will store the result in a new temporary.
Unlike a real CPU, LLVM allows you to have an unlimited number of
temporaries.  Just remember to give them unique names.

## Global Variables

Languages have variables where values can be loaded and stored. For
example, consider the following code in Wabbit:

```
// hello.wb
var x = 37;

func hello() {
    x = x + 100;
    return x;
}
```

Here is an LLVM translation of the above code that shows the details
of declaring, reading, and updating the value of a global variable:

```llvm
; hello.ll

@x = global i32 37            ;  var x int = 37

define i32 @hello()
{
    %1 = load i32, i32* @x   ; x = x + 100
    %2 = add i32 %1, 100
    store i32 %2, i32* @x
    ret i32 %2
}
```

Try it out:

```
shell % clang main.c hello.ll -o hello.exe
shell % ./hello.exe
hello() returned 137
```

The `@x = global i32 37` statement at the top declares a 32-bit
integer global variable named "x" with an initial value of 37.

To perform any kind of action on a variable, you must use temporary
variables.  The `load` instruction loads the value of a variable into
a temporary.  The `store` instruction saves the value of a temporary
back into the variable.  Carefully observe the use of types in these
instructions.  The `i32` refers to a 32-bit integer.  The `i32*` type
is a pointer (or memory address) that refers to a 32-bit integer.

If you modify the `main()` function to call `hello()` repeatedly,
you'll see the variable increase in value by 100 each time.

## Functions

It's sometimes nice to write functions that can compute useful things.
Let's modify our code to have a function that squares its argument.
In Wabbit, this function looks like this:

```
func square(n int) int {
    return n * n;
}
```

Here is LLVM code that performs the same thing:

```llvm
; hello.ll

@x = global i32 37                ; var x int = 37

define i32 @square(i32 %n)        ; func square(n) { return n*n; }
{
   %1 = mul i32 %n, %n
   ret i32 %1
}

define i32 @hello()
{
   %1 = load i32, i32* @x         ; x = square(x)
   %2 = call i32 @square(i32 %1)
   store i32 %2, i32* @x
   ret i32 %2
}
```

In this example, `define i32 @square(i32 %n)` defines a function
`square` that takes a 32-bit integer as input and returns a 32-bit
integer as a result.  Again, mathematical calculations have
to place their results into temporary variables, hence the instruction
`%1 = mul i32 %n, %n`.   It's okay
for different functions to reuse local names.  Any name
prefixed by `%` is local--meaning that it only has scope within
the enclosing function.

The instruction `%2 = call i32 @square(i32 %1)` calls the
function.  Pay careful attention to the types.  Both the
return type and the argument type must be specified when
calling the function.

If you run this, you should get the following output:

```
shell % clang main.c hello.ll -o hello.exe
shell % ./hello.exe
hello() returned 1369
```

## External Functions

Even though you're emitting low-level assembly code, there's no need
to completely reinvent the wheel from scratch.  One problem concerns
printing.  In Wabbit, there is a statement to print a value
to the screen.  How do you do that in LLVM?  The short answer is that
you don't (well, unless you're a masochist).  You do printing
in C.  Make a new file `runtime.c` and put a
`_print_int()` function in it like this:

```c
/* runtime.c */
#include <stdio.h>

void _print_int(int x) {
    printf("out: %i\n", x);
}
```

Now, suppose you wanted to call that function from LLVM.  To do it,
you first need to declare it:

```llvm
declare void @_print_int(i32 %x)
```

You can then call it like any other function.  Create the `runtime.c` file as
shown and then try this example:

```llvm
; hello.ll

declare void @_print_int(i32 %x)

@x = global i32 37                ; var x int = 37

define i32 @square(i32 %n)        ; func square(n) { return n*n; }
{
   %1 = mul i32 %n, %n
   ret i32 %1
}

define i32 @hello()
{
   %1 = load i32, i32* @x         
   call void @_print_int(i32 %1)   
   %2 = call i32 @square(i32 %1)
   call void @_print_int(i32 %2)
   store i32 %2, i32* @x
   ret i32 %2
}

```

Build your program by including the `runtime.c` file and run it.

```
shell % clang main.c hello.ll runtime.c -o hello.exe
shell % ./hello.exe
out: 37
out: 1369
hello() returned 1369
```

## Conditionals

Suppose you wanted to implement the equivalent of this Wabbit code in LLVM:

```
func max(a int, b int) int {
    var result int;
    if a > b {
        result = a;
    } else {
        result = b;
    }
    return result;
}
```

This presents a certain problem.  LLVM does not have structured
control with if-statements (or while-loops).  Instead, you have to
figure out how to do everything with branch (or goto) statements.

Programming with branches is not common practice--it may be something
that you've never even done before given that languages like Python
don't even allow it!   However, the gist of the idea is that you
introduce explicit branch labels into the code.  Here's what it
might look like in pseuodocode:

```
func max(a int, b int) int {
    var result int;
    var t = a > b;
    cbranch(t, L1, L2)     ; Goto L1 or L2 depending on t

L1:
    result = a;
    branch L3

L2:
    result = b;
    branch L3

L3:
    return result
}
```

LLVM will look similar to this.   Here's one possible encoding:

```llvm
define i32 @max(i32 %a, i32 %b)
{
   %result = alloca i32
   %1 = icmp sgt i32 %a, %b           ; r1 = a > b
   br i1 %1, label %L1, label %L2

L1:
   store i32 %a, i32* %result
   br label %L3

L2:
   store i32 %b, i32* %result
   br label %L3

L3:
   %2 = load i32, i32* %result
   ret i32 %2
}
```

The names `L1`, `L2`, and `L3` are branch labels.  The instruction `br label %L2` is
an unconditional goto.   The instruction `br i1 %1, label %L1, label %L2` is
a conditional branch that picks the target label based on the boolean value of `%1`.
The type `i1` represents a 1-bit integer (boolean).

There are a number of additional technicalities.  The `i32` type in LLVM
does not have any implied sign (positive/negative) attached to
it. Therefore, when comparing values you need to be specific about how
you want it to be handled.  The instruction `icmp sgt i32 %a, %b` is
performing a 32-bit integer signed greater-than operation (sgt).

The final result is placed into a local variable called `result`.
This variable is declared in advance using the `%result = alloca i32`
instruction.  Unlike the usual temporary variables, this variable
refers to a memory address that can only be accessed using `load` and
`store` instructions (similar to global variables).

Test out your new `max()` function by inserting a few calls into your
`hello()` function:

```llvm
define i32 @hello()
{
   %1 = load i32, i32* @x         ; x = square(x)
   call void @_print_int(i32 %1)
   %2 = call i32 @square(i32 %1)
   call void @_print_int(i32 %2)
   store i32 %2, i32* @x

   %3 = call i32 @max(i32 2, i32 3)    ; max(2, 3)
   call void @_print_int(i32 %3)

   %4 = call i32 @max(i32 3, i32 2)    ; max(3, 2)
   call void @_print_int(i32 %4)

   ret i32 %2
}
```

## Single Static Assignment

As previously mentioned, LLVM does NOT allow the reassignment of
any local variable.   This has some interesting (weird?) implications if
you try to be clever.  For example, you might be inclined to
write the `max()` function without the extra "load" and "store"
instructions like this:

```llvm
define i32 @max(i32 %a, i32 %b)
{
   %result = alloca i32
   %1 = icmp sgt i32 %a, %b           ; r1 = a < b
   br i1 %1, label %L1, label %L2

L1:
   %result = %a
   br label %L3

L2:
   %result = %b
   br label %L3

L3:
   ret i32 %result
}
```

This doesn't work at all. LLVM doesn't even have an instruction to "copy"
a variable like that.

There is an alternative approach that can be used, but it involves
one of LLVM's most mysterious features, the `phi` instruction.

```llvm
define i32 @max(i32 %a, i32 %b)
{
   %1 = icmp sgt i32 %a, %b
   br i1 %1, label %L1, label %L2

L1:
   br label %L3

L2:
   br label %L3

L3:
   %2 = phi i32 [ %a, %L1 ], [ %b, %L2 ]
   ret i32 %2
}
```

`phi` selects a value depending on the prior control path that
executed.  It looks weird, but this code picks `%2` to be the value
of `%a` if control went through label `L1`.  Otherwise, it picks the
value of `%b` if control went through label `L2`.  The mystery is
heightened by the fact that in this example, nothing actually appears
to happen in either of those branches.

In story-telling, there's a dramatic device known as [Chekhov's gun](https://en.wikipedia.org/wiki/Chekhov%27s_gun)
that says if something gets mentioned, there must be a reason.   

## Floating Point

So far, we've only written code that works with integers.  Floating
point numbers work the same way.  The LLVM `double` type should be
used to represent a 64-bit double precision floating point value.
Here is an example of a function that computes the value of `x*x + y*y`.

```llvm
define double @dsquared(double %x, double %y)
{
   %r1 = fmul double %x, %x
   %r2 = fmul double %y, %y
   %r3 = fadd double %r1, %r2
   ret double %r3
}
```

One critical part of floating point is that there are different
instructions for the math operators (e.g., `fadd`, `fmul`, etc.).
This reflects a similar distinction between integers and floating point
operations on actual hardware.  Also, if you need to write a floating point
constant, make sure you include a decimal point.

## Summary

This tutorial contains almost everything that you will need to general
LLVM code in the project.   Here is a mini-reference of important
details including an instruction reference.

### Types

Most operations in LLVM involve a type.  Here are some useful types
along with their Wabbit equivalent:

```
i32     ; 32-bit integer (int)
double  ; 64-bit float   (float)
i8      ; 8-bit integer  (char)
i1      ; 1-bit integer  (bool)
void    ; No value
```

### Functions

Instructions should always be enclosed in a function.  Functions are
declared as follows:

```llvm
define rettype @funcname(type1 %arg1, type2 %arg2, ...)
{
    ...
    ret rettype %result
}
```

### Literal Values and Constants

If writing out a constant value, use a decimal point to indicate the
difference between an integer and floating point.  For example:

```llvm
%1 = add i32, %x, 1234       ; x + 1234
%2 = fadd double, %y, 123.4  ; y + 123.4
```

A common mistake is to forget to use `0.0` for a floating point value of `0`.
Floating point numbers should be fully specified with all relevant decimal
points.  Scientific notation (e.g., `123e+07`) is not supported.

### Names and Variables

Variables are declared as local or global.  Local variables are
prefixed by `%`.  Global variables are prefixed by `@`.  To create
variables that can be later modified via load/store instructions, use the
following constructs:

```llvm
@name = global type initial           ; Global variable
%name = alloca type                   ; Local variable
```

The following instructions are used to access the value of the variables:

```llvm
; Load/store a local variable
%tmpname = load type, type* %name
store type %tmpname, type* %name

; Load/store a global variable
%tmpname = load type, type* @name
store type %tmpname, type* @name
```

Global variables must always have an initial value set.  It is typically `0` or `0.0`
depending on the type.

### Mathematical Operations

Mathematical operations usually have the general form:

```llvm
%target = op type %left, %right
```

Here are useful integer operations:

```llvm
%target = add i32 %left, %right             ; left + right
%target = sub i32 %left, %right             ; left - right
%target = mul i32 %left, %right             ; left * right
%target = sdiv i32 %left, %right            ; left / right
%target = and i32 %left, %right             ; left & right  (bitwise and)
%target = or i32 %left, %right              ; left | right  (bitwise or)
%target = xor i32 %left, %right             ; left ^ right  (bitwise xor)
%target = icmp slt i32 %left, %right        ; left < right
%target = icmp sle i32 %left, %right        ; left <= right
%target = icmp sgt i32 %left, %right        ; left > right
%target = icmp sge i32 %left, %right        ; left >= right
%target = icmp eq i32 %left, %right         ; left == right
%target = icmp ne i32 %left, %right         ; left != right
```

Here are useful floating point operations:

```llvm
%target = fadd double %left, %right         ; left + right
%target = fsub double %left, %right         ; left - right
%target = fmul double %left, %right         ; left * right
%target = fdiv double %left, %right         ; left / right
%target = fcmp olt double %left, %right     ; left < right
%target = fcmp ole double %left, %right     ; left <= right
%target = fcmp ogt double %left, %right     ; left > right
%target = fcmp oge double %left, %right     ; left >= right
%target = fcmp oeq double %left, %right     ; left == right
%target = fcmp one double %left, %right     ; left != right
```

### Function Calls and Returns

Use the following to call functions and to return values from a function:

```llvm
%target = call rettype @name(type1 %arg1, type2 %arg2, ...)
ret type %value
```

If you need to declare an external function written in C, use this:

```llvm
declare rettype @name(type1 %name1, type2 %name2, ...)
```

### Branches and Gotos

Labels are names followed by a colon (:).  For example:

```llvm
L1:
   ... instructions
L2:
   ... instructions
```

To jump to a label, use the `br` instruction.

```llvm
br label %NAME                      ; Unconditional branch to NAME
br i1 %test, label %L1, label %L2   ; Conditional branch to L1 or L2 based on %test
```

### Type Conversions

The following instructions can be used to convert between different datatypes.

```llvm
%target = sitofp i32 %source to double    ; int -> float
%target = fptosi double %source to i32    ; float -> int
%target = sext i8 %source to i32          ; char -> int
%target = trunc i32 %source to i8         ; int -> char
```

The `sext` instruction takes a smaller integer and sign-extends it to a larger
integer.  `trunc` takes a larger integer and truncates it to a smaller integer.
You can replace the types with any of the other integer variants.

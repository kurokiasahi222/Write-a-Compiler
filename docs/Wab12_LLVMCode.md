# Wab 12 - LLVM Code Generation

In the last few projects, you have converted Wab programs into
an intermediate representation that looks a lot like low-level code, but
which is still abstract in a lot of ways.

In this project, we're going to work to turn the code into something a
bit more concrete--specifically LLVM.   LLVM itself is another intermediate
representation, but the techniques that we'll use here are generally
applicable even if we were producing something else.

## Overview

At this point in the program, programs are represented as collections
of basic blocks.  These blocks contain sequences of instructions
for an abstract stack machine.  For example, this program

```
var x = 10;
x = x + 1;
print (23 * 45) + x;
```

has turned into the following:

```
global x;
func main() {
    L0:
        PUSH(10)
        STORE_GLOBAL(x)
        LOAD_GLOBAL(x)
        PUSH(1)
        ADD
        STORE_GLOBAL(x)
        PUSH(1035)
        LOAD_GLOBAL(x)
        ADD
        PRINT
        PUSH(0)
        RETURN
}
```

Our goal is to translate the instructions into concrete instructions specifically
targeted to LLVM. For example, creating something like this:

```
global x;
func main() {
    L0:
        LLVM(store i32 10, i32* @x)
        LLVM(%.0 = load i32, i32* @x)
        LLVM(%.1 = add i32 %.0, 1)
        LLVM(store i32 %.1, i32* @x)
        LLVM(%.2 = load i32, i32* @x)
        LLVM(%.3 = add i32 1035, %.2)
        LLVM(call i32 (i32) @_print_int(i32 %.3))
        LLVM(ret i32 0)
}
```

## Some LLVM Basics

LLVM instructions are going to be represented as text strings. These
strings will eventually be written to an output file--the final output
of our compiler.  Here are some LLVM instructions that correspond to the operations
we're using in the project:

```
; Math operations

{result} = add i32 {left}, {right}         ; result = left + right
{result} = mul i32 {left}, {right}         ; result = left * right
{result} = icmp eq i32 {left}, {right}     ; result = left == right
{result} = icmp slt i32 {left}, {right}    ; result = left < right

; Memory operations
%{name} = alloca i32                       ; local name;
{result} = load i32, i32* %{name}          ; result = local[name]
store i32 {value}, i32* %{name}            ; local[name] = value
{result} = load i32, i32* @{name}          ; result = global[name]
store i32 {value}, i32* @{name}            ; global[name] = value

; Control flow operations
br label %{name}                           ; GOTO(name)
br i1 {test}, label %{Lc}, label %{La}     ; CBRANCH(Lc, La)
{result} = call i32 (i32) @name(i32 {arg}) ; result = name(arg)
ret i32 {value}                            ; return value

; Printing
call i32 (i32) @_print_int(i32 {value})    ; print value
```

Note: In these instructions, anything in braces (e.g., `{result}`) is
a placeholder that gets replaced by a text string during code generation.
Also, pay careful attention to naming. Names starting with `%` are local
and names starting with `@` are global.  Finally, LLVM doesn't
provide support for printing.  To do that, we're going to call out to an
external function called `_print_int()` (which we must implement later). 

LLVM instructions are based on a style known as Three Address Code
(3AC).  On real CPUs, there is usually a small set of registers that
hold values.  Mathematical operations take their inputs from registers
and store their result in a register.  So, the CPU instructions might look
like this:

```
ADD R1, R2, R3   ; R1 + R2 -> R3
MUL R3, R4, R5   ; R3 + R4 -> R5
```

LLVM is similar except that you write the destination over on the
left side like this:

```
%r3 = add i32 %r1, %r2
%r5 = mul i32 %r3, %r4
```

Additionally, LLVM uses something known as [static single
assignment](https://en.wikipedia.org/wiki/Static_single-assignment_form)
to manage registers.  With SSA, each "register" can only be assigned
once in a program!   However, there are an infinite number of
registers.

That might sound strange, but basically you just make up a new
register name every time you perform a calculation and you store the
result in it.  You're free to refer to that register as much as you
want in subsequent operations--you just can't change its value once
assigned.

## Converting a Stack Machine to SSA

At first glance, it seems that converting our "stack" code to
LLVM SSA might be difficult.  In the stack code, you have an instruction
such as `ADD()` all by itself with no other information.  Where do
we get the input registers?  Where does the output go?

It turns out that the answer lies in the stack!  Start out by making
a helper function to create a new register name:

```
_n = 0
def new_register():
    global _n
    _n += 1
    return f'%.{_n}'
```

This function creates a new register name each time you call it.
For example, `%.1`, `%.2`, etc.  You will use it every time you
generate an LLVM instruction that produces a new value.  This basically
solves the problem of single assignment.

Next, make an `LLVM` node in your model for holding an LLVM specific
instruction string.  Make it a variant of `INSTRUCTION` so that you
can use it with the `BLOCK` class you already created.

```
# model.py
...

@dataclass
class LLVM(INSTRUCTION):
    op : str
```

Finally, make a function that walks through the instructions in a block
and "runs the stack" to create LLVM instructions.

```
def create_llvm(block : BLOCK) -> BLOCK:
    ops = [ ]
    stack = [ ]
    for instr in block.instructions:
        if isinstance(instr, PUSH):
            stack.append(str(instr.value))
            
        elif isinstance(instr, ADD):
            right = stack.pop()
            left = stack.pop()
            result = new_register()
            ops.append(LLVM(f'{result} = add i32 {left}, {right}'))
            stack.append(result)

        elif isinstance(instr, LOAD_LOCAL):
            result = new_register()
            ops.append(LLVM(f'{result} = load i32, i32* %{instr.name}'))
            stack.append(result)
        ...
	# You fill in more instructions
	...
	
    return BLOCK(block.label, ops)
```

In this code, the stack contains literal values such as `42` and
register names like `%.1`.  Mathematical operations like `ADD` will
pull these values off the stack, create a new register name, generate an operation,
and push the new register name onto the stack.   It might look like `ADD` is
actually running the code, but it's not. It's producing an LLVM instruction
using register name information that's on the stack.

The final result of the above function should be a new `BLOCK`
instance where every instruction has been converted into an `LLVM`
instruction.

## Your Task

Your task is to write a compiler pass that replaces all `INSTRUCTION` instances
in all blocks with a suitable `LLVM` instruction.   Put this in a file
called `llvmcode.py`.

Most of the coding will be in a single function called `create_llvm()` as
shown above.   None of this code should be particularly tricky.  It's
essentially a single for-loop with a big if-statement that replaces each
stack instruction with a suitable LLVM instruction.  Use the table of
LLVM operations above as a guide for how to do it.

## Formatting

As before, you'll want some way to view the output.  You should have some
way to distinguish LLVM instructions from the stack machine instructions.

## Example Output

Here's the `test/fact.wb` program:

```
// fact.wb
func fact(n) {
   if n < 2 {
       return 1;
   } else {
       var x = 1;
       var result = 1;
       while x < n {
           result = result * x;
           x = x + 1;
       }
       return result * n;
   }
}

var x = 1;
while x < 10 {
    print fact(x);
    x = x + 1;
}
```

After this compiler pass, you should have something that looks like this:

```
func fact(n) {
    L10:
        LLVM(%.0 = load i32, i32* %n)
        LLVM(%.1 = icmp slt i32 %.0, 2)
        LLVM(br i1 %.1, label %L0, label %L1)
    
    L0:
        LLVM(ret i32 1)
        LLVM(br label %L4)
    
    L1:
        LLVM(%x = alloca i32)
        LLVM(store i32 1, i32* %x)
        LLVM(%result = alloca i32)
        LLVM(store i32 1, i32* %result)
        LLVM(br label %L9)
    
    L9:
        LLVM(%.2 = load i32, i32* %x)
        LLVM(%.3 = load i32, i32* %n)
        LLVM(%.4 = icmp slt i32 %.2, %.3)
        LLVM(br i1 %.4, label %L2, label %L3)
    
    L2:
        LLVM(%.5 = load i32, i32* %result)
        LLVM(%.6 = load i32, i32* %x)
        LLVM(%.7 = mul i32 %.5, %.6)
        LLVM(store i32 %.7, i32* %result)
        LLVM(%.8 = load i32, i32* %x)
        LLVM(%.9 = add i32 %.8, 1)
        LLVM(store i32 %.9, i32* %x)
        LLVM(br label %L9)
    
    L3:
        LLVM(%.10 = load i32, i32* %result)
        LLVM(%.11 = load i32, i32* %n)
        LLVM(%.12 = mul i32 %.10, %.11)
        LLVM(ret i32 %.12)
        LLVM(br label %L4)
    
    L4:
        LLVM(ret i32 0)
    
}
global x;
func main() {
    L5:
        LLVM(store i32 1, i32* @x)
        LLVM(br label %L8)
    
    L8:
        LLVM(%.13 = load i32, i32* @x)
        LLVM(%.14 = icmp slt i32 %.13, 10)
        LLVM(br i1 %.14, label %L6, label %L7)
    
    L6:
        LLVM(%.15 = load i32, i32* @x)
        LLVM(%.16 = call i32 (i32) @fact(i32 %.15))
        LLVM(call i32 (i32) @_print_int(i32 %.16))
        LLVM(%.17 = load i32, i32* @x)
        LLVM(%.18 = add i32 %.17, 1)
        LLVM(store i32 %.18, i32* @x)
        LLVM(br label %L8)
    
    L7:
        LLVM(ret i32 0)
    
}
```

Note: At this point, the whole program consists of only 4 objects in the
model: `GlobalVar`, `Function`, `BLOCK`, and `LLVM`.


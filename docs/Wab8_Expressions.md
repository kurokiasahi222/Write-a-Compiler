# Wab 8 - Expression Code

Up to this point, the AST has represented program structure in the
domain of the source language. Yes, we have made some simplifications
and added some additional features to make certain facets of program
representation more explicit (for example, the separation of names
into local and global scope).  However, we're still mostly working
within the abstract world of "Wab."

In this project, we're going to make the leap from the abstract world
of Wab programs to the more concrete world of machines.  To do this,
we need to develop a machine-focused abstraction for programs.  In this
project, we'll start by focusing on expressions.

## A Machine View of Values and Expressions

In programs, a value is represented by an expression. An expression could be
a simple value like `42`, but it could also be something more complicated
like `(42 + x) * y`.  Expressions can be arbitrarily complicated as you
introduce more operators, function calls, and other features.  Expressions
are an abstraction. 

On a machine, a value is a collection of bits. Those
bits must exist somewhere in reality (e.g., on hardware).  This might
mean a CPU register or perhaps a specific location in memory.
Regardless of where the value lives, it's an actual thing that
you can point at and say "those bits there... that's the value." Values
are concrete.

Machines have low-level instructions that consume values as input and
produce new values as a result.  For example, primitive mathematical
operations such as add, subtract, and multiply.  

## Abstract Machines

In thinking about machines, it is often useful to think at a slightly
higher level than actual hardware.  Instead, you can define an
"idealized" machine that looks a lot like hardware, but makes certain
simplifications. 

A common approach in compilers is to generate code for just such an abstract
machine.  The code for this machine is often called "intermediate representation" referring to
the fact that it sits somewhere in-between the source program (e.g. "Wab") and
the actual machine code of a specific CPU (e.g., i386 assembler).  Although
intermediate representation is not actual machine code, it is easily
translated into such code--a step we will take in a later project.

## Expression Stacks

One useful machine abstraction for managing values and expression
computation is a stack.  A stack is a collection of stored values
along with two operations `PUSH(value)` and `POP()`.  `PUSH(value)`
creates a new value and `POP()` consumes a value.  Here is a stack
implementation in Python just to illustrate:

```
# The stack data
stack = [ ]

def PUSH(value):
    stack.append(value)

def POP():
    return stack.pop()
```

Here's are the two core operations:

```
>>> PUSH(23)   # stack = [ 23 ]
>>> PUSH(45)   # stack = [ 23, 45 ]
>>> POP()      # stack = [ 23 ]
45
>>> POP()      # stack = [ ] 
23
>>>
```

A stack can form the basis of implementing various machine operations such as
arithmetic. Here are some examples:

```
def ADD():
    right = POP()
    left = POP()
    PUSH(left + right)

def MUL():
    right = POP()
    left = POP()
    PUSH(left * right)
```

Here is an example of calculating `2 + 3*4` using the above
"instructions".  I strongly advise you to try this yourself:

```
>>> PUSH(2)         # stack = [ 2 ]
>>> PUSH(3)         # stack = [ 2, 3 ]
>>> PUSH(4)         # stack = [ 2, 3, 4 ]
>>> MUL()           # stack = [ 2, 12 ]
>>> ADD()           # stack = [ 14 ]
>>> POP()
14
>>>
```

Carefully notice that all of the operations such as `ADD` and `MUL`
implicitly operate on the stack.  That is, they only take their inputs from
the stack, and put their outputs (if any) back onto the stack.  Values
are not passed around or returned in any other way.

Digression: Stack-based computation is the basis of [Reverse Polish
Notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation) and
is a style of calculation popularized on HP calculators.

## Operations and Function Calls

In the above code, mathematical operators pulled their operands from the stack.
This approach extends to user-defined functions. Suppose you have a Wab function like this:

```
func f(x, y, z) {
    return (x + y) * z;
}
```

This function could be implemented as follows:

```
def f():
    # Get the input arguments
    z = POP()
    y = POP()
    x = POP()
    # Now carry out the calculation
    PUSH(x)
    PUSH(y)
    ADD()
    PUSH(z)
    MUL()
```

To make a function call such as `f(1, 2, 3)`, the following steps take place:

```
PUSH(1)        # Push arguments onto the stack
PUSH(2)
PUSH(3)
f()            # Call the function
```

Like operators, functions consume the stack to get their arguments.
The final result is placed on the stack with the function completes.

## A Machine View of Variables

In Wab, variable declarations such as `var x` are used to declare the
existence of a variable.  A variable name represents a place to hold a
value.  To illustrate, imagine that memory is an array of values,
initially set to 0:

```
>>> MEMORYSIZE = 100
>>> memory = [ 0 ] * MEMORYSIZE
>>>
```

The purpose of a `var x` declaration is to establish a location within
memory.  For example, suppose that `x` is located at memory location 12.
In that case, the name `x` would be set to 12 like this:

```
>>> x = 12        # var x; located at memory[12]
>>>
```

To connect memory with the stack machine, you need a `LOAD` instruction
that reads memory and puts the value on the stack.

```
def LOAD(address):
    PUSH(memory[address])
```

With this new instruction, here are the steps that carry out the
calculation `(42 + x)`

```
PUSH(42)
LOAD(x)
ADD()
```

## Global vs. Local Variables

Although memory is viewed as large array of values, a distinction must
be made between global and local variables.  Globals are variables
that persist for the entire duration of a running program.  Locals only
persist for the duration of a single function call.  Due to this difference,
global and local variables are managed in a slightly different way.

A global variable is represented by a fixed absolute memory address
that never changes. For example, you might say that `global x` is
located at memory address `12`.  If so, that's where `x` lives for all
eternity as the program runs.

A local variable is represented by an offset relative to a "frame"
pointer.  Imagine a function like this:

```
func f(x, y) {
    var z = x + y;
    return z;
}
```

In this function, there are three local variables, `x`, `y`, and `z`.
To hold these variables, a so called "activation frame" will be
created somewhere in memory.  We don't know exactly where it will
be (and frankly, we don't need to care much about that detail),
but think of a frame as a small sub-array located somewhere in memory.

```
    +-------+
    |   z   | 2
    |-------|
    |   y   | 1 
    |-------|
    |   x   | 0
    +-------+  <--- frame pointer
```

When a function executes, an implicit variable `frame` on the machine
will point to this memory region.  Local variables are assigned
unique indices like `x=0`, `y=1` and `z=2` that represent memory
locations within the frame.

To access a local variable, you need a slightly different load
instruction that incorporates the frame pointer into the address.  For
example:

```
frame = ...  # Current frame pointer (value varies)

def LOAD_LOCAL(offset):
    PUSH(memory[frame + offset])
```


## An Instruction Model for Expressions

With some preliminaries out of the way, our goal is to define an
instruction model for expression evaluation.   Using the stack
machine described above, let's define the following "instructions"

```
PUSH(value)         # Push a new value on the stack
ADD()               # +
MUL()               # *
LT()                # <
EQ()                # ==
LOAD_GLOBAL(name)   # Load global variable into stack
LOAD_LOCAL(name)    # Load local variable into stack
CALL(name, n)       # Call function name with n arguments
```

Your first task is to add these instructions to your model.  Go to the
`model.py` file and add a new category of object called `INSTRUCTION`.
Then, define all of the above instructions as variants.  This is
going to look pretty similar to what you already did with expressions
except that everything is going to be much more stripped down.

```
# model.py

# Other AST nodes here (from before)
...

class INSTRUCTION:
    pass

@dataclass
class PUSH(INSTRUCTION):
    value : int

@dataclass
class ADD(INSTRUCTION):
    pass

@dataclass
class MUL(INSTRUCTION):
    pass
    
...
```

One mental difficulty here is keeping track of the difference between
expressions, statements, and instructions.   I'm going to adopt a naming
convention of all-caps for instructions and anything else related to
the "machine" side of the compiler.  Thus, whenever you see anything
in `ALLCAPS`, assume that it is related to low-level machine code.

In addition to the above instructions, define a new expression variant
that holds a list of instructions.  For example:

```
# model.py
...

@dataclass
class EXPR(Expression):
    instructions : list[INSTRUCTION]
```

The purpose of this class is to be a container for the instructions that
comprise an expression.  For example, the expression `(42 + x)*y` is
represented as:

```
EXPR([
   PUSH(42),
   LOAD_LOCAL('x'),
   ADD(),
   LOAD_LOCAL('y'),
   MUL()
   ])
```

Since `EXPR` is defined as a type of `Expression`, you can freely use
`EXPR` with other AST nodes that used `Expression`.  For example, a
statement such as `print 42 + x;` could now be represented as:

```
Print(EXPR([PUSH(42), LOAD_LOCAL('x'), ADD()]))
```

This substitution is the basis of this project.  Note: We are only
concerned with the instructions.  We are not actually building an
interpreter or running the code (although you could certainly think
about that as a side project).

## Your Task

Your task is to write a new compiler pass that replaces *all*
expressions in the AST with `EXPR` instances containing the
instructions for that expression. To start, make a function
for converting expressions to instructions:

```
def expression_instructions(expr : Expression) -> EXPR:
    ...
```

This function takes an expression and converts it into an instruction
representation.  For example:

```
# 42 + x
a = expression_instructions(Add(Integer(42), LocalName('x')))
assert a == EXPR([PUSH(42), LOAD_LOCAL('x'), ADD()])

# (42 + x) * 65
b = expression_instructions(Mul(Add(Integer(42), LocalName('x')), Integer(65)))
assert b == EXPR([PUSH(42), LOAD_LOCAL('x'), ADD(), PUSH(65), MUL()])
```

The result of `expression_instructions()` is always going be a *single* `EXPR`
node that contains a complete list of instructions needed to arrive
at the final value for that expression.  Instructions are flat in the sense
that there is no tree structure or recursive definition.

Once you have `expression_instructions()` working, you need to write
code that walks through the AST and replaces all expressions with
`EXPR` instances.   This will work in the same way that you've already
written for other compiler passes--for example, it will look a lot like
the constant folding pass.

## Testing

You should be able to write standalone unit tests on the
`expression_instructions()` function as shown in the above example.
This may be easier than writing tests on large programs.

## Formatting

You should modify your code formatter to show `EXPR` nodes in an
easy-to-read form so that you can easily debug your compiler.  I'm
going suggest an approach that formats something like this:

```
EXPR([LOAD_LOCAL('n'), PUSH(2), LT()])
```

into the following:

```
[LOAD_LOCAL(n), PUSH(2), LT]
```

Admittedly, this is probably going to make the output look a little
"weird".  However, you should ideally have some way to see what's
happening without a lot of extra "line noise".

## A Complex Example

The file `tests/fact.wb` has the following Wab program which you should
now be able to parse:

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

When processed through this pass, all expressions should be replaced
by `EXPR` nodes.  The formatted output might look something like this:

```
func fact(n) {
    if [LOAD_LOCAL(n), PUSH(2), LT] {
        return [PUSH(1)];
    } else {
        local x;
        local[x] = [PUSH(1)];
        local result;
        local[result] = [PUSH(1)];
        while [LOAD_LOCAL(x), LOAD_LOCAL(n), LT] {
            local[result] = [LOAD_LOCAL(result), LOAD_LOCAL(x), MUL];
            local[x] = [LOAD_LOCAL(x), PUSH(1), ADD];
        }
        return [LOAD_LOCAL(result), LOAD_LOCAL(n), MUL];
    }
    return [PUSH(0)];
}
global x;
func main() {
    global[x] = [PUSH(1)];
    while [LOAD_GLOBAL(x), PUSH(10), LT] {
        print [LOAD_GLOBAL(x), CALL(fact, 1)];
        global[x] = [LOAD_GLOBAL(x), PUSH(1), ADD];
    }
    return [PUSH(0)];
}
```

In this code, `EXPR` nodes are represented by sequences of instructions
enclosed in square-brackets.  For example `[LOAD_LOCAL(n), PUSH(2), LT]`.
Yes, it looks like a weird hybrid of Wab and machine code, but that's
basically what you've got at the moment.

## Hints

One complication concerns the flattening of expressions.  Expressions are
represented by trees.  However, the result of `expression_instructions()` is
a single `EXPR` node containing a list of instructions.  To produce this,
you're going to have recursively flatten things like this:

```
def expression_instructions(expr):
    ...
    if isinstance(expr, Add):
       return EXPR(
                expression_instructions(expr.left).instructions
              + expression_instructions(expr.right).instructions
              + [ADD()])
    ...
```

We are ONLY focused on expressions right now.  If you find yourself
trying to implement assignment, printing, or other features, you're
working on the wrong problem.   That's a different project.

        




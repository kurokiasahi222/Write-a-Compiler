# Wab 2 - The Simplification

When you took a math class in school, you were probably asked
to "simplify your work."   As an example, suppose you wrote down the
following formula as the answer to a question on an exam:

```
y = 3*x + 20 + 13
```

Chances are, you might lose a "style" point because you didn't further simplify
it to the following:

```
y = 3*x + 33
```

Compilers follow a similar principle.  When a high-level program
is converted to a low-level program, there may be opportunities to
"simplify" the program.  This might improve efficiency, but it also
tends to make various parts of the compiler easier to implement.

In this project, we are going to take the model from Project 1 and
perform two different "simplification" steps on it.  The general idea
is that we'll take a program and translate it into an equivalent,
but "simpler" program.   This will also give you more practice
of working with the model from Project 1.

## Part 1 : Constant Folding

Your first task is to perform an optimization called "constant folding."  This only
involves the `Add()` and `Mul()` operations.  In a nutshell, you should
scan a program for patterns such as `Add(Integer(2), Integer(3))`.
Whenever encountered, you can evaluate it "in-place" and replace
the whole expression with `Integer(5)`.  

As an example, here is program 1 from the last project:

```
var x = 10;
x = x + 1;
print (23 * 45) + x;
```

You should translate this program into the following equivalent program:

```
var x = 10;
x = x + 1;
print 1035 + x;          // 23 * 45 = 1035
```

You should also be able to handle more complex expressions involving
constants.  For example, this code:

```
print (2 + 3) * 4;
```

Should simplify to:

```
print 20;
```

To do this, make a file called `foldconstants.py`.  In this file write
a few high-level functions just like you did for your formatter:

```
# foldconstants.py

from model import *

def fold_constants(program : Program) -> Program:
    ...

def fold_statements(statements: list[Statement]) -> list[Statement]:
    ...

def fold_statement(s: Statement) -> Statement:
    ...

def fold_expression(e: Expression) -> Expression:
    ...
```

These functions will take the model as input and return a
simplified model (if possible).  Most of your work will take place
in the `fold_expression()` function.  Here's an example of how it might
work:

```
prog = Program([Print(Add(Integer(2), Integer(3)))])
prog = fold_constants(prog)
# prog should now be Program([Print(Integer(5))])
```

Tip: Remember that the simplification process needs to descend into the
bodies of loops, if-statements, and functions.

## Part 2 : De-initialization

In Wab, variables are always declared using `var` before they are used.  When
they are declared, they are also initialized with a value.  For example:

```
var x = 42;
var y = 2 + x;
var z = (3 + y) * x;
```

Variables can later be reassigned with a new value.  For example:

```
x = y + 10;     // x must already be declared with var
```

These two features seem similar to each other. Perhaps there is
some redundancy that can be factored out.

In this step, we're going to perform a code simplification of variable
declarations.  Specifically, we're going to split variable declarations into two
parts--a declaration step and a separate assignment step.  As an example,
suppose you have the following declaration:

```
var y = 2 + x;
```

We're going to split it into the following:

```
var y;
y = 2 + x;
```

To do this, we will follow the same pattern that we did for constants.
Make a file called `deinit.py` and put the following code in it:

```
# deinit.py

from model import *

def deinit_variables(program : Program) -> Program:
    ...
    
def deinit_statements(statements: list[Statement]) -> list[Statement]:
    ...

def deinit_statement(s: Statement) -> list[Statement]:
    ...
```

Our main focus will be on the `deinit_statement()` function.  This
will check a statement to see if it's a `var` statement.  If so, we'll
rewrite it as a variable declaration followed by an assignment.
For example,

```
program = deinit_variables(Program([Variable('y', Add(Name('x'), Integer(10)))]))

# Produces the following result
# program = Program([ VarDecl('y'),
#                     Assignment(Name('y'), Add(Name('x'), Integer(10)))])
```                

Tips:

(1) Since variable declarations are turned into two separate
statements, the `deinit_statement()` function needs some way to return
multiple things.  This is why it returns a list above.  This list of
statements will replace the original statement.

(2) Variable declarations will no longer have initial values.  To
reflect this, you may want to make a different kind of AST/Model node.
For example, a `VarDecl` object that only has the variable name, but
no value.

(3) Don't forget that you need to descend into the bodies of if-statements,
while-loops, and functions.

## Part 3 - Formatting

As noted in the first project, the code formatter is an essential
debugging tool throughout the course.

Modify your code formatter so that it can still show the "code" after
it has been transformed.  If you introduced a new `VarDecl` node, make it
understand that and emit something nice like `var x;` as output.

## Part 4 - Setting up Compiler Passes

A compiler is constructed as a series of passes. Now would be a good time
to write a high-level `compile()` function that starts to put these passes
together.  For example:

```
def compile(program : Program) -> Program:
    # fold constants
    program = foldconstants.fold_constants(program)

    # Separate variable declarations and initialization
    program = deinit.deinit_variables(program)

    return program
```

You can use this `compile()` function in your `main.py` script.  For example:

```
# main.py

...
print('--- Program 1')
program1 = Program([ ... ])
compiled_program1 = compile(program1)
print(format_program(compiled_program1))

print('--- Program 2')
program2 = Program([ ... ])
compiled_program2 = compile(program2)
print(format_program(compiled_program2))

print('--- Program 3')
program3 = Program([ ... ])
compiled_program3 = compile(program3)
print(format_program(compiled_program3))

print('--- Program 4')
program4 = Program([ ... ])
compiled_program4 = compile(program4)
print(format_program(compiled_program4))
...
```

As before, we're going to keep working with the four sample programs.
However, as you add more compiler passes, you can now do that entirely
in the `compile()` function without having to change your test
program.

## Big Picture

In writing a compiler, one of the major challenges is managing complexity.
One approach to this problem is to take a data-centric view where we try
to work with the program model in some way.   Perhaps the program can be
simplified. Maybe certain features can be rewritten in terms of other
features.  The general techniques worked out in this project will prove
useful for other parts of the project.








# Wab 1 - The Model

Writing a compiler is mainly a project in data
manipulation.  In this case, the "data" represents a computer
program itself.   Thus, our starting point is the problem of representing
programs as data structures.

We will be working with the Wab language which is a subset of Wabbit.
See the [Wab Specifiction](Wab-Specification.md).

## Setup

Before you begin, make sure you remember to make your own branch
of the repo.

```
bash $ git checkout -b yourname
bash $ git push -u origin yourname
```

Find the `wab/` directory.  This is where you will code the first part
of your compiler implementation.  If you need to do any setup related
to your environment (creation of a project, etc.) do it here.

## Programs as Data

The input to a compiler is text called source code.  However,
a compiler doesn't want to work with your program as raw
text. Instead, a compiler prefers to use data representing the
structure of the program.  Usually this is a tree known as an
"Abstract Syntax Tree" (although I'll often use a more generic term
"model" to refer to the data representation of a program).

As an example, suppose you had a Wab statement such as this:

```
print 2 + 3;
```

One way to encode this statement is using classes or structures for the
different parts.  For example:

```
statement = Print(Add(Integer(2), Integer(3)))
```

Larger programs consist of multiple statements.  For example:

```
print 42;
print 2 + 3;
print x;
```

For multiples, you can use a list:

```
statements = [
   Print(Integer(42)),
   Print(Add(Integer(2), Integer(3))),
   Print(Name('x'))
   ]
```

`Integer`, `Print`, and `Add` are typically going to be class definitions.  For
example:

```
# model.py

from dataclasses import dataclass

# Abstract classes.  Used primarily for organization.
class Statement: pass
class Expression: pass

# Concrete classes. Represent specific features in Wab
@dataclass
class Print(Statement):
    value : Expression

@dataclass
class Integer(Expression):
    n : int

@dataclass
class Add(Expression):
    left : Expression
    right : Expression

# Top-level object representing an entire program
@dataclass
class Program:
    statements : list[Statement]
```

Here, each class represents a different programming language feature.
For an imperative language like Wab, features are separated into
two different flavors; "statements" that represent actions like printing
and "expressions" that represent values used in mathematical operations.
The top-level `Statement` and `Expression` classes are used to organize
variants of these things.  For example, both `Integer` and `Add` are
examples of expressions so they both inherit from `Expression`.

Note: If you are working in a language other than Python, you will
almost certainly want to organize your code in a similar way.  It
might not involve classes, but there should still be some separate
organization around statements and expressions. 

## Working with the Model

The data model forms the core of the whole compiler.  Almost
everything that you'll do later needs to work with this data
structure.  To learn how to use it, one of the first tools you should
write is a code formatter.  A code formatter takes a program,
represented using the model, and turns it back into nicely presented
source code text.  In some sense, a formatter is like a reverse
compiler.  It is also rather useful for debugging.

Here is an example of how you might write a formatter.

```
# Sample program
statements = Program([
     Print(Integer(42)),
     Print(Add(Integer(2), Integer(3)))
     ])

# Format a complete program
def format_program(program : Program) -> str:
    return format_statements(program.statements)

# Format a list of statements
def format_statements(statements : list[Statement]) -> str:
    code = ''
    for s in statements:
        code += format_statement(s)
    return code

# Format a single statement
def format_statement(s: Statement) -> str:
    if isinstance(s, Print):
        return 'print ' + format_expression(s.value) + ';\n'
    else:
        raise RuntimeError(f"Can't format {s}")

# Format a single expression
def format_expression(e: Expression) -> str:
    if isinstance(e, Integer):
        return str(e.n)
    elif isinstance(e, Add):
        return f'({format_expression(e.left)} + {format_expression(e.right)})'
    else:
        raise RuntimeError(f"Can't format {e}")

# Print a formatted version of the program
print(format_statements(program))
```

A key aspect of working with the data model is case-analysis.  You'll
write a generic function that is presented with a statement/expression and
then carries out some kind of action based on its type.

Another essential aspect of working with the model is recursion.
Programs almost always involve nested structures (for example, the
left and right sides of the `+` operator).  To handle this, formatting
will involve recursive calls to navigate the tree structure as
individual parts are formatted.

## Your Task

Your task is to define the core data structures used by the compiler
and to write a formatting function that turns those data structures
into source.  To do this, you will work with four different programs
that encode all of Wab's basic functionality.  

### Program 1: Variables, Math, and Printing

First, figure out how to encode and format the following program:

```
var x = 10;
x = x + 1;
print (23 * 45) + x;    // -> 1046
```

To do this, you'll need to figure out how to represent numbers, variables,
assignment, printing, addition, and multiplication.  You'll also
need to worry about multiple statements.

Note: The comment next to the `print` statement can be ignored. It is there
to indicate the expected output of the `print` statement
(which will be useful to know later).

### Program 2: Decision making

Your next task is to encode `if` statements.  How would you encode
and format this program?

```
var x = 3;
var y = 4;
var min = 0;
if x < y {
    min = x;
} else {
    min = y;
}
print min;   // -> 3
```

One complication here is that the program now includes nested code blocks
(e.g., the different branches of the `if` statement).   Although only
one statement is shown in each branch here, an arbitrary number of statements
can appear (this includes the possibility of having no statements).

An additional complexity arises in formatting.  When writing your
formatter, you should make it add indentation to nested blocks as appropriate to make
the output look nice.  The final output should look a lot like the
code shown above.

### Program 3: Looping

You should be able to have repeated operations.  Encode and format
the following program containing a `while` loop:

```
var result = 1;
var x = 1;
while x < 10 {
    result = result * x;
    x = x + 1;
}
print result;   // -> 362880
```

Like `if`, the body of a `while` loop can contain multiple statements
(or no statements).   Your formatter should indent the body to make it
look nice.

### Program 4: Functions

Your final task is to encode a function call.  How would you encode
and format this program?

```
func add1(x) {
    x = x + 1;
    return x;
}

var x = 10;
print (23 * 45) + add1(x);   // -> 1046
print x;                     // -> 10
```

Again, when formatting a function, the body should be appropriately
indented to make the output look nice.  Note: Although only one
function argument is shown, functions can take multiple arguments.

## How to Structure Your Code

Since we're starting from scratch, it might be a bit hard to know how to
structure the project.  My advice is to create a separate file
called `model.py` that has all of the data definitions in it:

```
# model.py

class Statement:
    pass

class Expression:
    pass

class Print(Statement):
    ...

class Integer(Expression):
    ...

class Add(Expression):
    ...

class Program:
    ...
```

Then make a file `format.py` that has the code formatting functions in it:

```
# format.py

from model import *

def format_program(program : Program) -> str:
    # Format an entire program
    ...

def format_statements(statements: list[Statement]) -> str:
    # Format a list of statements.
    ...

def format_statement(s: Statement) -> str:
    # Format a single statement
    ...

def format_expression(e: Expression) -> str:
    # Format a single expression
    ...
```

Finally, make a file `main.py` that carries out some basic testing.
The main file might look something like this.  Just to emphasize,
there are four short programs that need to be encoded (described above).

```
# main.py
from model import *
from format import format_program

print('--- Program 1')
program1 = Program([ ... ])
print(format_program(program1))

print('--- Program 2')
program2 = Program([ ... ])
print(format_program(program2))

print('--- Program 3')
program3 = Program([ ... ])
print(format_program(program3))

print('--- Program 4')
program4 = Program([ ... ])
print(format_program(program4))
```

The `main.py` program will serve as a testing area for early stages of
the project.  Eventually, it will get rewritten into something more
proper, but this is fine for now.   You are certainly free to write
more proper unit-tests in your project as well.

## Tips

You can implement the compiler in any programming language that you
wish.  One particular challenge is that you will need to think about
the hierarchical nature of the data (e.g., expressions can be nested inside
other expressions).  Thus, you may need to define some kind of
inheritance hierarchy, enum type, or similar structure.  Recursive
nesting may require pointers/references and other issues related to
memory management.

Also, be aware that writing a compiler involves some amount of string
and text processing (especially some of the later stages related
to parsing).  This is also something worth figuring out early--your
strategy for representing and manipulating strings.

This first part of the project can involve a steep learning curve as
you figure out the basics. This is normal!  Take it slow and work
out the details.  Other parts of the compiler project will reuse a lot
of the project that you work out here.   Also expect some refactoring 
as the project evolves.

Finally, keep in mind that we're only concerned with program structure.
We're not doing anything to verify correctness.  Nor are we running
the program.   This is purely an exercise in data structures.  You
shouldn't be adding any other functionality.

## The Importance of the Formatter

The code formatter that's written in this first project will be of central
importance throughout the entire course.  Compilers involve fairly
complex tree-structures that are difficult to look at.  Although
you can certainly just "print" the raw data structure, doing so
might make your head explode. For the purposes of debugging, it may be
useful to see programs represented in a more "human-readable"
form.

As we complete later project stages, we'll make minor modifications to
the formatter to incorporate new features and to adapt to changes that
we've made.  By the end of the final project, the formatter that we
started here should be able to output a program produced by any of
the later compiler stages.

## More on the Four Test Programs

The four test programs are correct Wab programs.  Eventually we'll
turn these programs into binary executables that can run.  However,
the programs are also meant to be simple.  You should be able to
understand what the programs are doing in your mind based on your past
experience with programming.  Wab is NOT meant to be tricky or mysterious.













# Wab 9 - Statement Code

What is the difference between an expression and a statement?  Whereas
an expression represents a value, a statement represents an
action like printing, storing a value, etc.  Actions consume values.
In some sense, statements are almost the opposite of expressions.

In this project, we're going to expand our code generation from
Project 5 with additional instructions representing "actions"
involving expressions. We'll then replace most of the statement nodes
in the AST with these instructions.

## Basic Actions

The Wab language is pretty simple and only has a few core "actions"
that involve values. Here they are in instruction form:

```
STORE_GLOBAL(name)   # Store into a global variable
STORE_LOCAL(name)    # Store into a local variable
PRINT()              # Print a value
RETURN()             # Return from a function
LOCAL(name)          # Create a new local variable
```

With the exception of `LOCAL()`, all of these instructions consume the
top element of the expression stack.

## Some Statement Examples

Suppose you had the following Wab code:

```
# x and y are local variables
print (2 + x)*y;
```

Here are the corresponding instructions:

```
PUSH(2)
LOAD_LOCAL('x')
ADD()
LOAD_LOCAL('y')
MUL()
PRINT()           # <<<< Action
```

Suppose that the above code was an assignment instead:

```
z = (2 + x)*y;
```

Here are the instructions:

```
PUSH(2)
LOAD_LOCAL('x')
ADD()
LOAD_LOCAL('y')
MUL()
STORE_LOCAL('z')   # <<<< Action
```

Almost every statement is going to involve instructions like this.  Code
to evaluate an expression will come first.  At the end, there's an
instruction to consume the value in some way.

## Your Task

Your task is to add the above instructions to your model.  These should
be added as variants of `INSTRUCTION` just like earlier instructions.
For example:

```
# model.py

# Other AST nodes here (from before)
...

class INSTRUCTION:
    pass

@dataclass
class STORE_LOCAL(INSTRUCTION):
    name : str

@dataclass
class PRINT(INSTRUCTION):
    pass
...
```

In addition to the above instructions, define a new statement variant
that holds a list of instructions. For example:

```
# model.py
...

@dataclass
class STATEMENT(Statement):
    instructions : list[INSTRUCTION]
```

The purpose of this class is to be a container for the entire set of
instructions that comprise a statement. For example, the statement
`print (42 + x)*y` can be written as:

```
STATEMENT([
   PUSH(42),
   LOAD_LOCAL('x'),
   ADD(),
   LOAD_LOCAL('y'),
   MUL()
   PRINT()
   ])
```

Since `STATEMENT` is defined as a type of `Statement`, you can freely use
`STATEMENT` with other AST nodes that used `Statement`.  

After you've defined `STATEMENT`, you need to write a compiler pass
that replaces value-oriented statements in the AST with `STATEMENT`
instances containing the instructions for that statement. To start,
make a function for converting statements to instructions:

```
def statement_instructions(statement : Statement) -> Statement:
    ...
```

This function takes a statement and converts it into an instruction
representation.  It requires that all expressions already be
converted to instructions (from the previous project). For example:

```
# print(42 + x)
a = statement_instructions(Print(EXPR([PUSH(42), LOAD_LOCAL('x'), ADD()])))
assert a == STATEMENT([PUSH(42), LOAD_LOCAL('x'), ADD(), PRINT()])

# z = (42 + x) * 65
b = statement_instructions(
  Assignment(LocalName('z'),
             EXPR([PUSH(42), LOAD_LOCAL('x'), ADD(), PUSH(65), MUL()])))
	     
assert b == STATEMENT([PUSH(42), LOAD_LOCAL('x'), ADD(),
                       PUSH(65), MUL(), STORE_LOCAL('z')])
```

Once you have `statement_instructions()` working, you need to write
code that walks through the AST and replaces statements with 
`STATEMENT` instances.


## What about if/while?

As you've probably noticed, nothing has been said about `if` and
`while` statements.  For now, you're going to leave `if` and `while`
statements in the AST as `If` and `While` nodes.  However, you will
replace the bodies of those statements with `STATEMENT` nodes.  Here
is an example:

```
# if x < 10 { print x + 1; } else { print x * 5; }

# Representation after expressions have been generated
c = statement_instructions(
    If(EXPR([LOAD_LOCAL('x'), PUSH(10), LT()]),
       [ Print(EXPR([LOAD_LOCAL('x'), PUSH(1), ADD()])) ],
       [ Print(EXPR([LOAD_LOCAL('x'), PUSH(5), MUL()])) ]))

# Representation after statements have been generated
assert c == If(EXPR([LOCAL_LOCAL('x'), PUSH(10), LT()]),
               [ STATEMENT([LOAD_LOCAL('x'), PUSH(1), ADD(), PRINT()]) ],
               [ STATEMENT([LOAD_LOCAL('x'), PUSH(5), MUL(), PRINT()]) ])
```

Carefully notice that it is only the two branches of the `if` that have
been altered.  The test and the `If` node itself remain.

## Testing

You should be able to write standalone unit tests on the
`statement_instructions()` function as shown in the above example.
This may be easier than writing tests on large programs.

## Formatting

As with expressions, I suggest having some way to easily view the
instructions that are being generated.  For statements, I would enclose
the instructions in square brackets, but print each instruction on its
own line.   So, something like this:

```
STATEMENT([PUSH(42), LOAD_LOCAL('x'), ADD(), PUSH(65), MUL(), STORE_LOCAL('z')])
```

would get formatted as follows:

```
[
   PUSH(42)
   LOCAL_LOCAL(x)
   ADD
   PUSH(65)
   MUL
   STORE_LOCAL(z)
]
```

Again, this is going to make the formatted output look pretty strange as it
evolves from Wab to machine code. 

## Complex Examples

Here's a more complex program found in `tests/fact.wb`:

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

Here's what that formatted program should look like after this compiler pass:

```
func fact(n) {
    if [LOAD_LOCAL(n), PUSH(2), LT] {
        [
            PUSH(1)
            RETURN
        ]
    } else {
        [
            LOCAL(x)
        ]
        [
            PUSH(1)
            STORE_LOCAL(x)
        ]
        [
            LOCAL(result)
        ]
        [
            PUSH(1)
            STORE_LOCAL(result)
        ]
        while [LOAD_LOCAL(x), LOAD_LOCAL(n), LT] {
            [
                LOAD_LOCAL(result)
                LOAD_LOCAL(x)
                MUL
                STORE_LOCAL(result)
            ]
            [
                LOAD_LOCAL(x)
                PUSH(1)
                ADD
                STORE_LOCAL(x)
            ]
        }
        [
            LOAD_LOCAL(result)
            LOAD_LOCAL(n)
            MUL
            RETURN
        ]
    }
    [
        PUSH(0)
        RETURN
    ]
}
global x;
func main() {
    [
        PUSH(1)
        STORE_GLOBAL(x)
    ]
    while [LOAD_GLOBAL(x), PUSH(10), LT] {
        [
            LOAD_GLOBAL(x)
            CALL(fact, 1)
            PRINT
        ]
        [
            LOAD_GLOBAL(x)
            PUSH(1)
            ADD
            STORE_GLOBAL(x)
        ]
    }
    [
        PUSH(0)
        RETURN
    ]
}
```

In reading this output, the code for each individual statement will be enclosed in
square brackets.

## Hints

You will continue to flatten AST nodes into instructions.  In this
case, statements should flatten any kind of expression code into
a resulting `STATEMENT` instance.  To do this, here's an example
of what it might look like:

```
def statement_instructions(statement):
    ...
    if isinstance(statement, Print):
       return STATEMENT(
                statement.value.instructions
              + [PRINT()])
    ...
```

        




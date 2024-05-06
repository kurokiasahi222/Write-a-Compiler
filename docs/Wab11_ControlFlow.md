# Wab 11 - Control Flow

At this point, you've almost completely transformed a Wab program into
machine instructions. Most of the program has turned into basic
blocks.  However, the last remaining detail concerns control flow.
Specifically, what do you do with `if` statements and `while` loops?

## Control Flow Explained

A basic block represents a sequence of instructions that execute
one after the other.  This is sequential control flow.
However, what happens when you get to the end of a basic block?

One possibility is that there are simply no more instructions.
Perhaps you've reached the end of a function and there is a
`RETURN` instruction.  Or maybe you're at the end of the program
altogether.  At this point, the program terminates. There is simply
nothing left to do.

Another possibility is that you need to jump to the start of
another basic block.   Effectively, this is a `goto` statement.
This is how a loop would work.   When you reach the end of the loop,
you jump back to the start of the loop to repeat its instructions.

A final possibility is that you need to make a decision about
where to go next.   This is the behavior of an `if-`statement.
Based on the outcome of a test expression, control jumps to
a block representing one of the two branches.

## Control Flow Instructions

Control flow can be encoded with two instructions:

```
GOTO(label)              # Jump to a basic block
CBRANCH(label1, label2)  # Jump to label1 if true, else jump to label2
```

Both instructions require block labels.  Recall from
the previous project that each basic block is given a uniquely
generated label.  The purpose of that label is for use
with these control-flow instructions.

These instructions may only appear at the *end* of a basic block
(think about it--if control is jumping elsewhere, any instructions
that follow would be ignored).  The `CBRANCH` instruction makes its
decision based on the value that's on the top of the expression stack
(which is consumed in the process).

## Encoding If-Statements

Suppose you have the following Wab function:

```
func f(x) {
    print x;
    if x < 10 {
        x = x + 1;
    } else {
        x = x * 2;
    }
    return x;
}
```

The representation of this function after the last project will look something
like this:

```
func f(x) {
    L1:
        LOAD_LOCAL(x)
        PRINT

    if [LOAD_LOCAL(x), PUSH(10), LT] {
        L2:
            LOAD_GLOBAL(x)
            PUSH(1)
            ADD
            STORE_GLOBAL(x)

    } else {
        L3:
            LOAD_GLOBAL(x)
            PUSH(2)
            MUL
            STORE_GLOBAL(y)
	    
    }
    L4:
        LOAD_LOCAL(x)
        RETURN
}
```

Carefully observe that there are four basic blocks.  Your task
is to link them together with `GOTO` and `CBRANCH` statements, eliminating
the if-statement. This will involve changing the above code into the following:

```
func f(x) {
    L1:
        LOAD_LOCAL(x)
        PRINT
        GOTO(L5)                 # <<< Added

    L5:                          # New block added for the test
        LOAD_LOCAL(x)
        PUSH(10)
        LT
        CBRANCH(L2, L3)          # <<< Added

    L2:
        LOAD_GLOBAL(x)
        PUSH(1)
        ADD
        STORE_GLOBAL(x)
        GOTO(L4)                 # <<< Added

    L3:
        LOAD_GLOBAL(x)
        PUSH(2)
        MUL
        STORE_GLOBAL(y)
        GOTO(L4)                 # <<< Added

    L4:
        LOAD_LOCAL(x)
        RETURN
}
```

A few observations:

- A new block (`L5`) was created to hold the instructions for the
  conditional test.  This block ends with the `CBRANCH` instruction
  to pick a path.

- Blocks `L1`, `L2`, and `L3` are modified to have `GOTO` instructions
  added at the end.   The initial block `L1` is linked to the block with
  the conditional test.  Blocks `L2` and `L3` have a `GOTO` instruction
  added to jump the block of code (`L4`) that appears after the if-statement.

- The entire function is now nothing but a series of blocks that
  are linked together.

It may help to draw a picture of the blocks along with the gotos.

```
            +-----------------+
            |        L1       |
            |       ....      |
            |     GOTO(L5)    |
            +-----------------+
                     |
                     v
            +-----------------+
            |        L5       |
            |       ....      |
            |  CBRANCH(L2,L3) |
            +-----------------+
               /           \
              /             \
+-----------------+      +-----------------+
|        L2       |      |        L3       |
|       ....      |      |       ....      |
|     GOTO(L4)    |      |     GOTO(L4)    |
+-----------------+      +-----------------+
             \              /
              \            /
            +-----------------+
            |        L4       |
            |       ....      |
            |     RETURN()    |
            +-----------------+
```

## Encoding While-Loops

Suppose you have the following Wab function:

```
func f(x) {
    var n = 0;
    while n < x {
        print x;
        n = n + 1;
    }
    return 0;
}
```

The representation of this function after the last project will look something
like this:


```
func f(x) {
    L1:
        LOCAL(n)
        PUSH(0)
        STORE_LOCAL(n)

    while [LOAD_LOCAL(n), LOAD_LOCAL(x), LT] {
        L2:
            LOAD_GLOBAL(n)
            PRINT
            LOAD_GLOBAL(n)
            PUSH(1)
            ADD
            STORE_GLOBAL(n)
    }
    L3:
        PUSH(0)
        RETURN
}
```

Again, we need to link the blocks together using `GOTO` and `CBRANCH`
instructions.  This will be similar to an `if`-statement.  Here's a
final result:

```
func f(x) {
    L1:
        LOCAL(n)
        PUSH(0)
        STORE_LOCAL(n)
        GOTO(L4)         # <<< Added

    L4:                  # New block added for loop test
        LOAD_LOCAL(n)
        LOAD_LOCAL(x)
        LT
        CBRANCH(L2, L3)  # <<< Added

    L2:
        LOAD_GLOBAL(n)
        PRINT
        LOAD_GLOBAL(n)
        PUSH(1)
        ADD
        STORE_GLOBAL(n)
        GOTO(L4)         # <<< Added

    L3:
        PUSH(0)
        RETURN
}
```

Like the `if`-statement, a new block (`L4`) is created to hold
instructions for the loop test.   The initial block `L1` is modified to jump
to `L4`.  The loop-body (`L2`) is also modified to jump back to `L4` to make the loop repeat.
The `CBRANCH` instruction in `L4` decides whether or not to
execute the loop body or skip to the basic block that appears after
the loop (`L3`).

Again, a picture might help:


```
            +-----------------+
            |        L1       |
            |       ....      |
            |     GOTO(L4)    |
            +-----------------+
                     |
                     v
            +-----------------+
      +---->|        L4       |
      |     |       ....      |
      |     |  CBRANCH(L2,L3) |
      |     +-----------------+
      |              |   \_________
      |              v             |
      |     +-----------------+    |
      |     |        L2       |    |
      |     |       ....      |    |
      +-----|     GOTO(L4)    |    |
            +-----------------+   /
                      ___________/
                     |
                     v
            +-----------------+
            |        L3       |
            |       ....      |
            |     RETURN()    |
            +-----------------+
```

## Your Task

Your task is to add `GOTO` and `CBRANCH` instructions to your model.
These should be variants of `INSTRUCTION` just like all other instructions.
You then need to write a compiler pass that replaces all `if` and `while`
statements with `BLOCK` instances that are properly linked together.

The final result of this pass will be a collection of global variable
declarations and function definitions.  Each function definition should
consist of nothing more than a list of `BLOCK` instances.  Every
`BLOCK` should end with either a `RETURN`, `GOTO`, or `CBRANCH` instruction.

## An Example

Consider the `tests/fact.wb` program from earlier:

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

Here is what the program looks like after the `while` and `if` statements
have been replaced in this project:

```
func fact(n) {
    L10:
        LOAD_LOCAL(n)
        PUSH(2)
        LT
        CBRANCH(L0, L1)
    
    L0:
        PUSH(1)
        RETURN
        GOTO(L4)
    
    L1:
        LOCAL(x)
        PUSH(1)
        STORE_LOCAL(x)
        LOCAL(result)
        PUSH(1)
        STORE_LOCAL(result)
        GOTO(L9)
    
    L9:
        LOAD_LOCAL(x)
        LOAD_LOCAL(n)
        LT
        CBRANCH(L2, L3)
    
    L2:
        LOAD_LOCAL(result)
        LOAD_LOCAL(x)
        MUL
        STORE_LOCAL(result)
        LOAD_LOCAL(x)
        PUSH(1)
        ADD
        STORE_LOCAL(x)
        GOTO(L9)
    
    L3:
        LOAD_LOCAL(result)
        LOAD_LOCAL(n)
        MUL
        RETURN
        GOTO(L4)
    
    L4:
        PUSH(0)
        RETURN
    
}
global x;
func main() {
    L5:
        PUSH(1)
        STORE_GLOBAL(x)
        GOTO(L8)
    
    L8:
        LOAD_GLOBAL(x)
        PUSH(10)
        LT
        CBRANCH(L6, L7)
    
    L6:
        LOAD_GLOBAL(x)
        CALL(fact, 1)
        PRINT
        LOAD_GLOBAL(x)
        PUSH(1)
        ADD
        STORE_GLOBAL(x)
        GOTO(L8)
    
    L7:
        PUSH(0)
        RETURN
}
```

Observe that each function now consists of nothing other than basic blocks.
Moreover, every block is terminated by a `GOTO`, `CBRANCH`,
or `RETURN`.

## Hints

One complication in this project is that you're building links between different
blocks--essentially turning the blocks into a kind of cyclic graph.  You may find
that your code is suddenly turning into a rather complex mess of bookkeeping.

One trick that may help in this construction is the observation that every
basic block is always going somewhere--blocks aren't allowed to simply
fall off the end.  They have to end with a `GOTO`, `CBRANCH`, or `RETURN`
instruction.  With this in mind, it might make sense to write a high-level
function `link_blocks()` like this:

```
def link_blocks(statement : Statement, next_label:str) -> list[BLOCK]:
    blocks = [ ]
    if isinstance(statement, If):
        ...
    elif isinstance(statement, While):
        ...
    elif isinstance(statement, BLOCK):
        # Create a link from this block to the next one
        blocks.append(BLOCK(statement.label,
                            statement.instructions + [ GOTO(next_label) ]))

    ...
    return blocks
```

In this function, the next block is explicitly identified by the
the `next_label` argument.   You will use this to properly create links
from the current block to the next one as shown for `BLOCK` above.
The handling of `If` and `While` statements is a bit more complicated, but
you can also use `next_label` for creating a links to the statement
that appears *after* the `If` or `While`.

The other hint (which is related) is that linking blocks is much
easier if you process everything in reverse.  Start with the *last*
block in a function and then call `link_blocks()` on statements in
reverse order working your way to the first block.  This will give you
the label names you need to give to the `next_label` argument.

## What about global variables and functions?

At this point in the project, every part of the program has been
transformed into low-level instructions except global variable
declarations and function definitions (i.e., the AST still contains
nodes for both of those objects).

These declarations don't really represent machine instructions,
but are an abstraction concerning program organization.
For example, the purpose of a global variable declaration is to
define the existence of a global variable.  There's not
much else that can be said about it.  Similar, a function declaration
defines the function name and input parameters.  However, this
information doesn't translate into any actual code by itself.

Going forward, we're going to keep this high level structure
of a program being structured as a collection of global variable
and function definitions.   Low-level code will only be found inside
function definitions (the function body). 


# Wab 10 - Basic Blocks

In the previous project, you rewrote each statement as a collection of
instructions. For example, the following program:

```
var x = 10;
x = x + 1;
print (23*45) + x;
```

Turned into something like the following:

```
global x;
func main() {
    [
        PUSH(10)
        STORE_GLOBAL(x)
    ]
    [
        LOAD_GLOBAL(x)
        PUSH(1)
        ADD
        STORE_GLOBAL(x)
    ]
    [
        PUSH(1035)
        LOAD_GLOBAL(x)
        ADD
        PRINT
    ]
    [
        PUSH(0)
        RETURN
    ]
}
```

In this project, you're going to perform a simplification where any sequence of
one or more statement blocks are merged together into a single block of instructions
known as a "basic block."   A basic block is a labeled sequence of instructions
that contain *no* control-flow features (i.e., no if/while loops).
For example, here's the above program with all of the statements merged into a
single basic-block:

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

In this output, `L0` is a generated block label name.

## Your Task

Your task is to add a new `BLOCK` class to your model.  It should be a variant of `Statement`.
A block contains a uniquely generated label name along with a list of instructions.  For example:

```
@dataclass
class BLOCK(Statement):
    label : str
    instructions : list[INSTRUCTION]
```

Next, write a compiler pass that walks the entire AST and replaces *all* instances
of `STATEMENT` with instances of `BLOCK`.  If multiple `STATEMENT` nodes appear together
in sequence, they should be merged together into a single `BLOCK` instance.

Each `BLOCK` instance should have a uniquely generated label name.  

Certain AST nodes such as `If`, `While`, and `Function` will be left in-place, but any
code that makes up their bodies should be converted into blocks.  Note: since `BLOCK` is
defined as a valid `Statement`, you shouldn't have to change anything about the definition
of those nodes in the model.

## Formatting

Again, you will want to have some way to view the blocks.  I suggest modifying the
formatter to print blocks by first printing the block label on its own line and then
all of the enclosed instructions.  For example, as shown above.

## An Example

Here is a more complex example.  Consider the `tests/fact.wb` program:

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

After converting it to basic blocks, it should look like this:

```
func fact(n) {
    if [LOAD_LOCAL(n), PUSH(2), LT] {
        L0:
            PUSH(1)
            RETURN
        
    } else {
        L1:
            LOCAL(x)
            PUSH(1)
            STORE_LOCAL(x)
            LOCAL(result)
            PUSH(1)
            STORE_LOCAL(result)
        
        while [LOAD_LOCAL(x), LOAD_LOCAL(n), LT] {
            L2:
                LOAD_LOCAL(result)
                LOAD_LOCAL(x)
                MUL
                STORE_LOCAL(result)
                LOAD_LOCAL(x)
                PUSH(1)
                ADD
                STORE_LOCAL(x)
            
        }
        L3:
            LOAD_LOCAL(result)
            LOAD_LOCAL(n)
            MUL
            RETURN
        
    }
    L4:
        PUSH(0)
        RETURN
    
}
global x;
func main() {
    L5:
        PUSH(1)
        STORE_GLOBAL(x)
    
    while [LOAD_GLOBAL(x), PUSH(10), LT] {
        L6:
            LOAD_GLOBAL(x)
            CALL(fact, 1)
            PRINT
            LOAD_GLOBAL(x)
            PUSH(1)
            ADD
            STORE_GLOBAL(x)
        
    }
    L7:
        PUSH(0)
        RETURN
    
}
```

At first glance, it will look pretty similar to what we did with
statements.  The main difference is that each block of instructions
now has a unique name (e.g., `L1`, `L2`, `L3`, etc.).  In some places,
adjacent statements are merged into a single block, For example, block
`L1` contains the instructions for two statements.

## Hints

This project should not involve a lot of code.  You can probably implement it in
a way that's fairly similar to Project 4.

You will need some way to generate unique label names.  I made a
global function `gen_label()` that produces a unique name every time it's
called by updating a global counter.

To merge adjacent `STATEMENT` blocks, you'll need to have access to the previous
statement when walking though a statement list.  So, there's a bit of extra
bookkeeping involved with that.

To make it easier to view the resulting AST, you should add support for `BLOCK`
nodes to your code formatter.








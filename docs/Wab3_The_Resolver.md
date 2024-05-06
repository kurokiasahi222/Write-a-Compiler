# Wab 3 - The Resolver

In Wab, you can declare both global and local variables using `var`.
A global variable is any variable declared at the top level.  It
can be accessed by any code that follows.  A local variable is any
variable declared inside a code-block such as a function,
if-statement, or while-loop. A local variable is only visible inside
that same block of code.

```
// A sample Wab program

var x = 23;            // x is global (top-level)

func f(y) {            // y is local (function parameter) 
    var r = x + y;     // r is local (declared inside a function)
    return r;
}

if x > 10 {
    var t = 2*x;       // t is local (inside a code block)
    print t;
} else {
    print f(x);
}
```

The scope of a variable is determined by its surrounding
context.   In this project, you're going to transform the
model to make the scoping explicit. You will walk the AST, record
information about variable names, and rewrite all variable access
to explicitly encode whether the variable is global or local.

## Expanding the AST

In your definition of the AST, you already have some classes related to variables.

```
# model.py
...

# Represents 'var x;'
@dataclass
class VarDecl:
    name : str

# Represents a bare variable name like 'x' used in an expression
@dataclass
class Name(Expression):
    name : str
```

You are going to add four specialized classes into the mix.

```
# Variable declarations  (e.g., 'var x')
class GlobalVar(VarDecl): pass
class LocalVar(VarDecl): pass

# Variable references (e.g., 'x')
class GlobalName(Name): pass
class LocalName(Name): pass
```

These classes refine the concept of a variable to explicitly include its scope.

## Your Task

Your task is to walk the AST and rewrite all variable declarations and name
references to use these new classes.  As an example, suppose you had
this code:

```
var x = 42;
func f(y) {
   var t = x * y;
   return t;
}
print f(x);
```

The AST for this code (after working Project 2) is going to look like this:

```
ast = Program([
   VarDecl('x'),
   Assignment(Name('x'), Integer(42)),
   Function('f', ['y'], [
       VarDecl('t'),
       Assignment(Name('t'), Mul(Name('x'), Name('y'))),
       Return(Name('t')
       ]),
   Print(Application('f', [Name('x')]))
   ])
```

You will transform this AST into the following:

```
ast = Program([
    GlobalVar('x'),
    Assignment(GlobalName('x'), Integer(42)),
    Function('f', ['y'], [
        LocalVar('t'),
        Assignment(LocalName('t'),
                   Mul(GlobalName('x'), LocalName('y'))),
        Return(LocalName('t'))
        ]),
    Print(Application('f', [GlobalName('x')]))
    ])
```

To do this, you will write code that's similar to what you wrote in Project 2.
Your primary focus will be on `Name`, `VarDecl`, and `Assignment` nodes.

Create a file `resolve.py` and put the following top-level function in it.

```
# resolve.py

from model import *
def resolve_scopes(program : Program) -> Program:
    ...
```

You'll additionally add functions for handling statements and expressions as you
did before.

## Error Handling

At some point, you might realize that various name-related programming
errors can occur.  For example, what happens if code refers to an
undeclared variable name?

```
// Bad Wab program

func f(x) {
    return x + y;  // y undeclared variable name
}

print f(2);
```

For now, our strategy will be to do nothing and assume that the
input program is "correct."   In other words, you can just let
the compiler crash if a bad input is given.

Eventually, we'll want to fix that (and if you're feeling motivated,
you can make your compiler print a helpful error message).   However,
this is a task for later.

## Modifying the Formatter

To make debugging easier, modify your code formatter to recognize the
new local/global variable AST nodes.  Have the formatter clearly indicate the
scope by printing output like this:

```
global x;
global[x] = 42;
func f(y) {
    local t;
    local[t] = (global[x] * local[y]);
    return local[t];
}
print f(global[x]);
```

Yes, this output no longer looks like a Wab program, but it makes it
possible for us to inspect the transformed AST and look for problems.

## Hooking it all together

Your `compile()` function should now look like this:

```
def compile(program):
    program = fold_constants(program)
    program = deinit_variables(program)
    program = resolve_scopes(program)
    return program
```

## Tips

1. Code will walk and modify the AST in the same manner as in Project 2.

2. You will need to track additional information about variable names. Specifically, you
need to remember scope information about variable names so that you can create
the proper `GlobalName()` or `LocalName()` AST nodes.  Use a set or dict for tracking this.

3. Every function definition resets the environment of local variables when walking
the function body.  This should make some sense if you think about how every
function is its own little environment (the variables defined inside one function
don't interact with variables defined inside other functions). 

4. Don't overcomplicate things.  In this stage of the project, we're only
focused on one specific thing---is a variable local or global?  It's a yes/no question. That's it.
You might be inclined to try and solve other sorts of problems.  Don't.

## Some Additional Tests

Although you will run your resolver on the four test programs, bugs related
to scoping are often subtle and difficult to debug.  With that in mind, here
are some additional test cases that you should check:

### Block Scope

Variables defined inside code blocks are always local.  Example:

```
var x = 2;         // Global
if x < 10 {
    var y = x + 1; // Local
    print y;
}
```

You should write some unit tests that verify this.

### Shadowing

Another potential issue with variables concerns the shadowing of global
variables.   When functions define variables, those variables are distinct
from those in the outer environment and from other functions. For example:

```
var x = 2;           // Global

func f(y) {
    var x = y * y;   // Local (NOT the same x as global)
    return x;
}

print f(x);     // --> 4
print x;        // --> 2
```

Program 4 also has some shadowing in it. Pay careful attention to it.

### A Puzzler

What is supposed to happen in this program?

```
var x = 2;        // Global

func f(y) {
    print x;         // --> ???
    var x = y * y;
    print x;         // --> ???
    return x;
}

print f(10);  
print x;             // --> ???
```

I'm not asking you to do anything specific with this example--just to
think about it.   What do you think the program *should* do?   Try
converting it to a similar program in a language that you know (say Python)
and run/compile it.

## Big Picture

One mantra of programming is that "explicit is better than implicit."  In this
project, we're rewriting the AST to make the nature of variables explicit.
This will make our life a lot easier later because we won't have to write
code that tries to handle issues of scoping--we'll just already know because
it will have been explicitly encoded.










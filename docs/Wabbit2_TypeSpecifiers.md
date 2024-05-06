# Wabbit 2 - Type Specifiers

Wabbit allows expressions to take on different types such as `int`,
`float`, and `char`.  Normally, the type is inferred
from a value.  For example, when you write this:

```
var x = 1234;
```

Wabbit already knows that the type will be `int`.    However, in
some cases, the type can't be inferred. For example,

```
var x;         // Type of x???
func f(x) {    // Type of x???  Return type???
    ...
}
```

To handle these cases, explicit types are sometimes required.
For example:

```
var x int;
func f(x int) int {
   ...
}
```

The `Wab` project did not require such types.   However, you're going
to fix that now.

## Your Task

Your task is to add type annotations to variable declarations and
function definitions.  This will primarily involve changing the AST
and parser, but might involve other parts of the compiler as well.

First, a type will now be required for variable declarations where no
value is given.

```
var x int;
```

Second, types are now required on function definitions.
For example:

```
func f(x int, y int) int {
    return x + y;
}
```

## Advice

Adding type specifiers should not involve huge changes, but may have a
far reaching effect on existing unit tests and compiler phases.  If
you've already written tests, make sure those tests still pass.  You
may have to go through the tests and account for the extra type
specifiers that have been added.

Of particular concern is code related to the handling of functions.
Since functions now have a return type and argument types, you may
have a lot of broken code (throughout the compiler) where you need
to make sure you're handling this extra information correctly.

In this early stage, we are adding specifiers, but basically ignoring
them.  Think of this step as making a place for types in the compiler.
Interpretation of the types will come later.

## Testing

The file `wabbit/tests/specifier.wb` has a test program you
can try.

You can find earlier tests with type annotations added in `wabbit/tests/fact.wb` and
`wabbit/test/fib.wb`.  These tests should compile and produce the same output
as they did before.



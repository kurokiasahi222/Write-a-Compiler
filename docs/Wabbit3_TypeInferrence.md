# Wabbit 3 - Type Inferrence

**All expressions must have a type.**  That is your task in this project.

You need to implement a new compiler pass.  This pass will walk the AST and
perform two basic functions:

1. Attach a type to ALL expressions.
2. Report any type-related errors found in the process.

Conceptually, this pass may look a bit like the "resolver" pass that
determined the scope of variables.  However, instead of concerning
itself with scopes, this pass will concern itself with types.  Like
the resolver, variable names will need to be tracked.  Specifically,
you will need to record the type of each variable name and use that
when figuring out the type of subsequent expressions.

Wabbit follows some basic rules concerning the mixing of types.
Specifically, mixed type operations are NEVER allowed.  So, an
expression such as `x + y` is illegal if `x` and `y` are different
types.  For arithmetic operations, the result type is always the same
as the input types.  For relations such as `x < y`, `x` and `y` must
be the same type and the result is always a boolean.

## Testing

This project is mostly concerned with the internals of the compiler
and may be somewhat difficult to test directly.   You should try to
implement some defensive programming to ensure that the first requirement
is met (all expressions must have a type).

Type-related errors can probably be tested by trying some simple
examples like this:

```
func f(x int, y float) int {
    var z = x + y;      // Type error. int + float
    return z;
}
```

Note: almost all of the Wabbit related tests involve properly structured
programs that are free of errors.  When starting out, it's fine to
code on the "happy path."  However, you should still make some effort
to *NOT* compile programs that have obvious type errors.

Finally, as you work on this project, try to make sure that programs
involving only involving integers still work.  For example, make sure
the `wabbit/tests/fact.wb` and `wabbit/tests/fib.wb` programs can
compile and still produce proper output.




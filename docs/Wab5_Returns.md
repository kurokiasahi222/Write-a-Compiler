# Wab 5 - Returns

Wab functions always return an integer result.  If no `return` statement
is present, 0 is returned.   Although we might debate the merits of this
design, that is not our goal here.  Instead, we're merely going to
make this implicit behavior explicit.

## Your Task

Your task is to write a compiler pass that checks every function to see
if it ends with an explicit `return` statement or not.  If not, you'll
add an explicit `return 0;` at the end.   As an example, suppose
this is your Wab function:

```
func f(x) {
    print 2*x;
}
```

You'll change the function into the following:

```
func f(x) {
    print 2*x;
    return 0;
}
```

If the function already ends with a `return` statement, you'll
do nothing. Leave the function "as is."

## Hints

This pass should require very little work.  You can probably implement it with
a single for-loop and a few checks to make sure functions have the proper form.
This pass should be added *after* the previous pass which added a `main()`
function.

## Big Picture

This pass continues the process of preparing Wab programs for further analysis.
Basically, our goal is to make everything as "explicit" as possible.  In this
case, we're addressing a very focused problem of what to do when functions
don't have a final `return`.

This is potentially something we might want to change later.  For example,
perhaps a missing `return` should warrant an error message or warning. Perhaps
the language is changed to return `None` or some other kind of result.  Either
way, this pass establishes a place in the compiler to address this issue.


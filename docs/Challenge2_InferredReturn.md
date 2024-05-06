# Challenge 2 - Inferred Return Type

When you added types to Wabbit, you were forced to include type specifiers
in a few selected places where types could not otherwise be inferred.
For example, on variable declarations with no values:

```
var x int;
```

You also needed to include types on function definitions:

```
func square(x int) int {
    return x * x;
}
```

However, function definitions are a bit weird.  Technically speaking,
the only type ambiguity is found on function arguments.  The return
type could be inferred by looking at uses of the `return` statement inside the function.

You task is to do exactly this.  Make the return type specifier on functions
optional. If ommitted, the return type will be inferred from usage of the return
statement alone.   Here is an example:

```
func square(x int) {
    return x * x;           // Returns int
}

print 3 + square(10);       // OK

func fsquare(x float) {
    return x * x;           // Returns float
}

print 3.0 + fsquare(10.0);  // OK
```

## Complications

Of course, there are some tricky edge cases.  What happens here?

```
func f(x int) {
    if x > 0 {
         return 1.5;     // float
    } else {
         return 2;       // int
    }
}
```

Or in this case where only one branch of an if-statement is present?

```
func f(x int) {
    if x > 0 {
        return 1.5;
    }
    // What happens when we fall off the end?
}
```

## Testing

The file `wabbit/tests/returntype.wb` has a test program.

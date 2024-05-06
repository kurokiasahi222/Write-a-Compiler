# Wabbi 3 - Optional Value

Modify the parser so that a variable can be declared without an
initial value.  For example:

```
var x;        // No initial value

def setx(v) {
    x = v;
    return x;
}
print x;          // -> ?
print setx(123);  // -> 123
print x;          // -> 123
```

## How to Proceed

This should be a minor modification to the parser that might only take
a few minutes.  You already introduced a value-free variable
declaration AST node as part of Project 2.  You should be able to reuse that
here.

## Testing

The file `wabbi/tests/optvalue.wb` has a test program.


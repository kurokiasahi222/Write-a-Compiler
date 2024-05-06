# Challenge 1 - For Loops

Many programming languages have a for-loop for iteration.  Suppose
you wanted to add it to Wabbit.  For example, being able to write the following
code:

```
for (var n = 0; n < 10; n = n + 1) {
    print n;
}
```

You could add this feature in the usual way and modify all parts of
the compiler to understand it. However, you could also syntactically
translate the for-loop into the following while-loop:

```
var n = 0;
while n < 10 {
   print n;
   n = n + 1;
}
```

This is your task--add support for a for-loop via a syntax
translation.  Part of the challenge is knowing where to do it.  Is
this handled solely by the parser? Or is it handled elsewhere?

## Testing

The file `wabbit/tests/forloop.wb` has a test program.

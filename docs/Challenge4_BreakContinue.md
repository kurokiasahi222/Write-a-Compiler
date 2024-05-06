# Challenge 4 - Break and Continue

Most programming languages with loops have `break` and `continue` statements
to alter control flow.  For example:

```
var n = 0;
while n >= 0 {
    print n;
    if n >= 10 {
        break;      // Exits the loop
    }
    if n < 10 {
        n = n + 1;
        continue;   // Skips back to top
    }
    n = 0;
}
```

The above example is a bit pathological in the sense that the loop
condition `n >= 0` is always true and that the final statement
in the loop appears to reset the counter back to zero.   However, if you
study the code closely, you'll realize that the code counts from
0 to 10 and stops.

Loops can also be nested:

```
var x = 0;
while x >= 0 {
    if x == 10 {
        break;
    } else {
       var y = 0;
       while y >= 0 {
           if y == 10 {
               break;
           } else {
               print x * y;
               y = y + 1;
           }
      }
      x = x + 1;
    }
}
```

## Your Task

You need to add `break` and `continue` statements to Wabbit and
make sure that the above code example works.

## Advice

You will need to add these features to the tokenizer, parser, and AST.
However, most of the challenge will involve the code generator involving
control flow. `break` and `continue` effectively implement a kind of
"goto" statement.   Knowing where to go involves knowing about the
surrounding context--especially if there are nested loops.

## Testing

The file `wabbit/tests/breakcontinue.wb` has a test program.

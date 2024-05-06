# Challenge 3 - Short Circuit Evaluation

Programming languages usually have logical operators like `and` and `or`
to form more complex relations.  For example:

```
if x > 0 and x < 5 {
   print x;
}

if x != 0 and (1/x) > 0 {
   print x;
}
```

The logical operators don't work quite in the same way as a normal
math operator.   Usually with a math operator, the left and right
sides evaluate first, then the operation takes place.  Logical
operators do something else.  Instead, the left-hand side is evaluated
first.  If the result of this evaluation determines the final outcome,
the right hand side is abandoned (and never evaluated).

You can see this behavior if you look closely at a language like Python.
Try this:

```
>>> x = 0
>>> 0 + 1/x
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ZeroDivisionError: division by zero
>>> 0 and (1/x):
0
>>>
```

Carefully notice that the final `and` operator did NOT produce a
division-by-zero error.   The `1/x` never evaluated.  This
is known as "short-circuit" behavior.

## Your Task

Your task is to add `and` and `or` operators to Wabbit that
extend the capabilities of relations. For example:

```
var x = 0;
if x != 0 and 100/x > 0 {
    print x;                 // Prints nothing
}
if x == 0 or 100/x > 0 {
    print x;                 // -> 0
}
```

These operators must exhibit short-circuit behavior in that the right-hand
side does NOT evaluate if the left side determines the result.  For example,
if the left side of `and` is false, the result is false. If the left side of `or`
is true, the result is true.

Underneath the hood, short circuit behavior behaves the same as if you had
written the above code like this:

```
var x = 0;
if x != 0 {         
    if 100/x > 0 {      // and 
        print x;
    }
}

if x == 0 {       
    print x;
} else {  
    if 100/x > 0 {     // or
        print x;
    }
}
```

## Advice

You will need to modify your tokenizer, parser, and AST to accommodate the
new `and` and `or` operators.  However, can you implement the operators
without making major changes to anything else?

## Testing

The file `wabbit/tests/shortcircuit.wb` has a test program.

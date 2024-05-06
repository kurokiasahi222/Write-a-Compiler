# Wabbi 5 - Line Numbers (Optional)

It would be nice if you could give users a helpful error message
when they give your compiler bad input--as opposed to just crashing
with an exception.   Your task is simple: Modify the tokenizer and parser
to Wab so that when a problem is detected, a nice error message is
printed along with the offending line number.  Feel free to include
any additional information that might be helpful to the user.

For example, suppose the input program is this:

```
// badwabbit.wb
var x = 23;
print x ** 3;
```

You might print an error message like this:

```
Line 3: Syntax error at '*'
```

After an error occurs, it's fine for your compiler to stop
all further processing and quit.

## Tips

This project only involves the tokenizer and the parser. No other part
of Wab needs to be modified.  There is a risk that you might break
some unit tests for parsing, but this shouldn't affect other parts of
the compiler.

## Further Thought

How hard would it be to modify your parser to print an error,
recover in some way, and keep on parsing--possibly to uncover
even more errors?  Note: I'm NOT asking you to do this.

## Even Further Thought

How would you obtain the line number if some other part of the
compiler (say, the variable resolver) wanted to print an error
message with the line number attached to it?  Note: I'm NOT
asking you to do this.  Well, unless you want to.



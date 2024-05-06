# Wabbi 7 - Balanced Braces (Optional)

Parentheses `( )` and braces `{ }` are used for grouping things together.
Whenever used, they are always balanced.  For example, a `{` must
always have a closing `}`.   Moreover, braces can be nested. When nested, the
opening and closing braces have to be structured properly.  For example, an
opening `{` can't be closed by a `)`.

Making a mistake with braces is a common programming syntax error.  It would be nice
if your compiler could detect this problem and print a useful error message
back to the user.  For example, maybe even identifying the appropriate line
numbers (see the line number project).

For example:

```
func f(x) {
   print x;
}}              // Note extra "}"
```

Here is a possible error message:

```
Line 3: Found '}' with no opening '{'
```

You could try address this error in the parser, but it will be tricky and
annoying.  A better approach is to write a dedicated compiler pass that does
nothing more than check the tokens for proper brace structure.

## Your Task

Create a file `bracecheck.py` that implements a new compiler stage that sits
between tokenizing and parsing.  You will write the following function:

```
def bracecheck(tokens : list[Token]):
    ...
```

This function will walk the token sequence looking for proper brace structure.
If any kind of error is detected, have the function print an error or raise
an exception.  As with other errors, compilation should immediately stop if
a problem is detected.

## Tips

You can probably implement this check using a stack.  Whenever you see an
opening brace, push it on the stack.  Whenever you see a closing brace,
check the stack to see if it matches up with a proper opening brace.

## Thoughts

Providing a good user experience is a harder problem than it
looks. Trying to hack it into the tokenizer or parser can cause a
coding nightmare.  Sometimes a tricky problem might be easier to solve
with a small dedicated compiler phase like this.

## Tests

The files `wabbi/tests/badbrace.wb` and `wabbi/tests/badparen.wb`
are two test programs you can try.


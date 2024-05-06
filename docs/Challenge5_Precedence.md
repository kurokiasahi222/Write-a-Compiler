# Challenge 5 - Operator Precedence

To this point, we've been working with a restriction that limits all
mathematical operations to two operands.  For example, `x + y` is legal,
but `x + y + z` is disallowed.  The goal of this project is to fix this
and allow expressions with mixed operations such as `x + y * z`.

This project only involves the parser. No other parts of the compiler
should require changes.

## Handling Multiple Operands

In your parser, you have probably written a rule to handle binary
operators that looks like some variation of this:

```
class Parser:
    def parse_binop(self):
        left = self.parse_term()
        if self.accept('PLUS'):
            op = Add
        elif self.accept('MINUS'):
            op = Sub
        elif self.accept('TIMES'):
            op = Mul
        elif self.accept('DIVIDE'):
            op = Div
        else:
            return left
        right = self.parse_term()
        return op(left, right)
```

This parsing rule only handles a single pair of operands. For example,
`x + y`.

Your first task is to modify it to allow an arbitrary number of arguments.
To do this, you need to understand associativity.  If you have an
expression such as `a + b - c + d`, it associates to the left and
evaluates as `(((a + b) - c) + d)`.  Looking at that, you realize
that operators are being collected in some way.  This can be coded using
a loop:

```
class Parser:
    def parse_binop(self):
        left = self.parse_term()
        while True:
            if self.accept('PLUS'):
                op = Add
            elif self.accept('MINUS'):
                op = Sub
            elif self.accept('TIMES'):
                op = Mul
            elif self.accept('DIVIDE'):
                op = Div
            else:
                return left
            right = self.parse_term()
            left = op(left, right)      # Create a new left side
```

This might require a bit of study, but the general idea is that the code sits
in a loop collecting operators until there are no more to parse. On
each iteration, a new left-hand side is created.  This gives left associativity.

## Handling Precedence

A second problem with expressions concerns operator precedence.  Operators
such as `+` and `*` have different precedence levels as illustrated
in this example:

```
print 2 + 3 * 4;      // Produces 14    2 + (3 * 4)
print 2 * 3 + 4;      // Produces 10    (2 * 3) + 4
```

There are different strategies for handling this, but one approach is
to break parsing into multiple levels.   You write a separate parsing
function for each precedence level and string them together like this:

```
class Parser:
    def parse_addop(self):
        left = self.parse_mulop()
        while True:
            if self.accept('PLUS'):
                op = Add
            elif self.accept('MINUS'):
                op = Sub
            else:
                return left
            right = self.parse_mulop()
            left = op(left, right)

    def parse_mulop(self):
        left = self.parse_term()
        while True:
            if self.accept('TIMES'):
                op = Mul
            elif self.accept('DIVIDE'):
                op = Div
            else:
                return left
            right = self.parse_term()
            left = op(left, right)
```

Alternatively, you might try to implement the [Shunting Yard Algorithm](https://en.wikipedia.org/wiki/Shunting_yard_algorithm).

## Your Task

Your task is to implement operator precedure for mathematical operations and to
allow for more complex expressions.

## Testing

The file `wabbit/tests/precedence.wb` has a test program to try to see if you've
implemented things correctly.






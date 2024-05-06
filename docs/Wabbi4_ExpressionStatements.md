# Wabbi 4 - Expression Statements

The `print` statement sure seems a lot like a function call.  The main
difference between `print` and a function is the lack of a return value.
For example,

```
print (2 + 3);         // Print statement (no return value)

func printval(v) {       // Function (implicitly returns 0)
    print v;
}

var x = printval(2+3);   // Function call
```

In this code, there is no way to even use `printval()` except in some
context where an expression is expected.  So, you have to assign its result
to a variable or use it in some other way.

Most programming languages allow you to evaluate expressions without
saving their value--often for tasks such as I/O. For example, you can
usually write this:

```
printval(2+3);        // Function, return value is disregarded.
```

In this project, we'll add this feature.  

## Expressions as Statements

Your task is to modify the parser to allow arbitrary expressions
to be used as a solitary statement.  The key syntactic feature is
that you have an expression all by itself followed by a semicolon (`;`).
For example:

```
printval(2+3);
2+3;
```

For this, you should define a new `AST` node called `ExprStatement`.
This node is a statement that contains an expression inside.

You should then modify any other necessary parts of the compiler
to recognize this statement and generate code for it.  Again,
the semantics are that the expression will evaluate, but the
resulting value will be ignored or thrown away.

## Tips

The hardest part of this project will be the parser.  You must
recognize a bare expression followed by a semicolon. For example:

```
x + y;
x;
f(x);
```

There is a tiny bit of a parsing conflict between this and
variable assignment.  For example:

```
x + y;       // Expression as statement
x = y;       // Assignment
```

Here, looking at the name `x` is not enough to predict what is being
parsed afterwards.  So, part of the project involves figuring out how
to resolve that problem.

## Tests

The file `wabbi/tests/exprstatement.wb` has a short test program
to try.




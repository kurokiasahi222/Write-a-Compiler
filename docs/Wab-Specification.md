# Wab

The "Wab" language is the starting point for our compiler project.
"Wab" is a subset of the final "Wabbit" language we're
building.  The goal is to strip away a lot of initial complexity,
but still have something that looks like a programming language.
More features will get added later.

## 1. Wab Overview

Wab has a standard set of features you're used to in programming including
numbers, variables, conditionals, loops, and functions.  Here is a
sample Wab program that prints the first 10 factorials:

```
func fact(n) {
    var result = 1;
    var x = 1;
    while x < n {
       result = result * x;
       x = x + 1;
    }
    return result * n;
}

var n = 0;
while n < 10 {
   print fact(n);
   n = n + 1;
}
```

## 2. Program Structure

A Wab program consists of a sequence of statements and
definitions. Code executes top-to-bottom like a script.  Simple
statements are terminated by a semicolon. For
example:

```
print 3;
var a = 4;
print 3*a;
```

A comment is denoted by `//` and extends to the end of the line. For example:

```
var a = 4;    // This is a comment
```

Statements involving control flow expect blocks of statements enclosed in
braces.  For example:

```
if a < b {
   print a;
} else {
   print b;
}
```

## 3. Datatypes

Wab only supports a single integer datatype.  All math operations and variables
work with integers only.  This restriction will be lifted once we move to
the full Wabbit project.

## 4. Variables

Variables are declared using the `var` keyword and must always be
given an initial value.  For example:

```
var x = 0;
```

Variable names must start with a letter, but may include letters and
numbers afterwards.  The following words are reserved and may not be
used as a variable name:

```
else func if print return while var
```

Variables are managed in two different scopes.  Any variable declared
at the top-level is a global variable.  Global variables may be accessed
from anywhere in a program.  A variable that's declared inside a code block
(function, if-statement, while-loop) is a local variable.  

## 5. Printing

To print a value, use the `print` statement.  For example:

```
print 3;
print x;
print 3 + x;
```

## 6. Math operations

The following math operations are provided:

```
a + b      // Integer addition
a * b      // Integer multiplication
```

Wab does NOT allow multiple operations of `+` or `*` to be chained together.
For example:

```
var x = 2 + 3;      // Good
var x = 2 + 3 + 4;  // Bad!
var x = 2 + 3 * 4;  // Bad!
```

However, Wab does allow explicit grouping with parentheses.  So you
can write this:

```
var x = 2 + (3 * 4);  // Good
var x = (2 + 3) * 4;  // Good
```

This restriction makes Wab a bit annoying to use (and we may fix it later).  However,
for now it means that you'll have to explicitly break complex math expressions into
parts where each part only performs a single operation.  As an example,
if you're working on your kid's high-school algebra homework and want to
print the value of `6*x*x + 3*x - 8`, you'll have to write it like this:

```
print (((6 * x) * x) + (3 * x)) - 8
```

## 7. Conditionals

Use `if` to write a conditional. For example:

```
if a < b {
   statement1;
   statement2;
} else {
   statement3;
   statement4;
}
```

Both branches of an `if`-statement must be present.  A branch may contain no statements
inside the `{ }` however. 

A relation or boolean must immediately follow the `if` keyword. The following relations
are understood:

```
a == b
a < b
```

Where `a` and `b` are math expressions (see previous section).
Relations may NOT appear anywhere else except immediately after an
`if` or `while` keyword.  Also, Wab does NOT allow a singular value to
be used as a relation.  Thus, this code is illegal.

```
if a {       // NO!  Must use a relation
   ...
} else {
   ...
}
```

This restriction on relations may look a little strange, but it has to
do with relations producing boolean values (e.g., true or false).  As
specified, Wab only works with integers.  Thus, any operation
involving a "non-integer" needs to be handled as a special case.  This
is one of those cases.

## 8. Loops

Use `while` to write a loop.  For example:

```
while a < b {
    statement1;
    statement2;
}
```

Like `if`, a relation must appear after the `while` keyword.

## 9. Functions

A function is defined using `func` like this:

```
func f(x, y) {
    statement1;
    statement2;
    ...
    return result;
}
```

Functions only take integer arguments and return an integer.

The `return` statement must be used to return a value.  If control
reaches the end of a function without encountering a `return`
statement, 0 is returned.

Any variable defined inside a function is local to that function (i.e.,
the name is not visible to code outside).   This includes the names of
the function parameters.

Wab does NOT allow functions to be defined inside any code block
enclosed by braces.  This means that functions can only be defined at the
"top level" and NOT inside the body of an if-statement, while-loop, or
other function definition.

To call (or "apply") a function, specify its name and provide input arguments inside
parentheses. For example:

```
print f(2, 3);
var y = f(x);
```

Function calls may be freely used in math expressions.  So, a
statement like this is valid:

```
print f(2,3) + f(4,5);     // OK
```

as is the statement:

```
print f(2 + 3, 4 + 5);    // OK
```

or this:

```
print f(f(2,3), f(4,5));  // OK
```

## 10. Formal Syntax

The following grammar is a description of Wab syntax written as a PEG
(Parsing Expression Grammar). Tokens are specified in ALLCAPS and are
assumed to be returned by the tokenizer.  In this specification, the
following syntax is used:

```
{ e }   --> Zero or more repetitions of e.
e1 / e2 --> First match of e1 or e2.
```

A program consists of zero or more statements followed by the
end-of-file (EOF).  Here is the grammar:

```
program : statements EOF

statements : { statement }         ; Note: { ... } means repetition

statement : print_statement
          / variable_definition
          / if_statement
          / while_statement
          / func_definition
          / return_statement
          / assignment_statement

print_statement : PRINT expression SEMI

variable_definition : VAR NAME ASSIGN expression SEMI

assignment_statement : NAME ASSIGN expression SEMI

if_statement : IF relation LBRACE statements RBRACE ELSE LBRACE statements RBRACE

while_statement : WHILE relation LBRACE statements RBRACE

func_definition : FUNC NAME LPAREN parameters RPAREN LBRACE statements RBRACE

parameters : NAME { COMMA NAME }

return_statement : RETURN expression SEMI

expression : term PLUS term
           / term TIMES term
           / term

relation : expression LT expression
         / expression EQ expression

term : INTEGER
     / NAME LPAREN arguments RPAREN
     / NAME
     / LPAREN expression RPAREN

arguments : expression { COMMA expression }

```

The following tokens are defined.  Text in quotes is literal text. Otherwise,
a regular expression is given.

```
NAME    = [a-zA-Z_][a-zA-Z_0-9]*
INTEGER = [0-9]+
PLUS    = "+"
TIMES   = "*"
LT      = "<"
EQ      = "=="
ASSIGN  = "="
LPAREN  = "("
RPAREN  = ")"
LBRACE  = "{"
RBRACE  = "}"
SEMI    = ";"
COMMA   = ","
ELSE    = "else"
IF      = "if"
FUNC    = "func"
PRINT   = "print"
RETURN  = "return"
VAR     = "var"
WHILE   = "while"
```







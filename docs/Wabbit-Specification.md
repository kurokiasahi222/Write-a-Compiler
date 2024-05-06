# Introducing Wabbit

We are going to implement a small programming language called
"Wabbit."  This document provides an overview of the complete language.

Wabbit is a small statically typed language (like C, Java, Rust,
etc.). The syntax is roughly C-like.  It is meant to look familiar.

## 0. A Taste of Wabbit

Here is a sample Wabbit program that computes the first 30 
Fibonacci numbers:

```
/* fib.wb -  Compute fibonacci numbers */

// A function declaration
func fibonacci(n int) int {
    if n > 1 {              // Conditionals
        return fibonacci(n-1) + fibonacci(n-2);
    } else {
        return 1;
    }
}

var n = 0;                // Variable declaration
while n < 30 {          // Looping (while)
    print fibonacci(n);   // Printing
    n = n + 1;            // Assignment
}
```

This program, although small, illustrates most of Wabbit's basic features
including variables, functions, conditionals, looping, and printing.  

## 1. Syntax

Wabbit programs consist of statements, expressions, and definitions.
Simple statements are terminated by a semicolon. For example:

```
print 3;
var a = 4;
```

A single-line comment is denoted by `//`.  For example:

```
var a = 4;    // This is a comment
```

Multiline comments can be written using `/* ... */`. For example:

```
/* 
 This is a
 multiline
 comment.
*/
```

An identifier is a name used to identify variables, types,
and functions.  Identifiers can include letters, numbers, and the
underscore (_), but must always start with a non-numeric character
The following reserved words may not be used as an identifier:

```
and else func if not or print return while var
```

A numeric literal such as `12345` is an integer.  A
numeric literal involving a decimal point such as `1.2345` is
a floating point number.  

A character literal such as `'h'` represents a single text
character. The character `'\n'` represents a newline.

Curly braces are used to enclose blocks of statements.  For
example:

```
if a < b {
   statement1;
   statement2;
} else {
   statement3;
   statement4;
}
```

## 2. Types

Wabbit implements a static type system similar to C or Java.

### 2.1 Built-in types

There are three built-in datatypes; `int`, `float`, and `char`.

`int` is a signed integer.  `float` is a double precision floating
point number.  `char` is a single character. 

### 2.2 Defining Variables

Variables are declared using a `var` declaration.  If no initial value is given,
then a type must be specified.  Otherwise, the type is inferred from the initializer.
```
var a int;
var b = 3.14159;    // type float
```

It is illegal to specify both an initializer and a type.  So, you NEVER
write the following:

```
var b float = 3.14159;    // Error. Both type and initializer given
```

Variables are mutable and can be changed using an assignment statement.
For example:

```
a = 123;
```

Assignment to a variable not previously declared with `var` is an error.

## 3. Operators and Expressions

An expression represents code that evaluates into a value (i.e., an
integer, float, etc.). Think of it as code that could
legally go on the right-hand-side of an assignment:

```
x = expression;
```

### 3.1 Math operators

Integer and floating point types support the binary operators `+`,
`-`, `*`, and `/` with their standard mathematical meaning.  Operators
require both operands to be of the same type.  For example, `x / y` is
only legal if `x` and `y` are the same type.  The result type is
always the same type as the operands.  Note: for integer division, the
result is an integer and is truncated (e.g., `8/3` produces a result of `2`).

Numeric types also support the `-` unary operator. For example:

```
z = -y;
z = x * -y;
```

Character literals support no mathematical operations whatever. A
character is simply a "character" and that's it.  

### 3.2 Relations

All types can be compared, using the following operations.

```
a < b
a <= b
a > b
a >= b
a == b
a != b
```

However, a relation may ONLY appear in the context of an `if` or `while`
statement.  For example:

```
if a < b {
   ...
}

while a < b {
   ...
}
```

It is an error to use relations outside of this.  For example:

```
var t = a < b;    // ERROR: Relation may only appear in if/while
```

### 3.3 Associativity and precedence rules

All operators are restricted to only take two arguments and may
not be combined with other operators unless explicit parentheses
are used.  For example:

```
print x + y;            // OK
print x + y * z;        // ERROR
print (x + y) * z;      // OK
```

This restriction means that Wabbit doesn't need to implement the
implicit associativity and precedence rules that you learned
in math class.  A downside is that it can be a bit verbose if
you need to write a complex expression.  For example:

```
// Compute: 6*x*x + 3*x - 7
print (((6*x)*x) + (3*x)) - 7;
```

Yes, in an actual programming language, you may want to make this
more convenient.  However, we've only got a week.

## 4. Control Flow

Wabbit has basic control-flow features in the form of `if`-statements and `while`-loops.

### 4.1. Conditionals

The `if` statement is used for a basic conditional. For example:

```
if (a < b) {
   statements;
   ...
} else {
   statements;
   ...
}
```

The `else` clause in a conditional is optional.

### 4.2 Looping

The `while` statement can be used to execute a loop.  For example:

```
while n < 10 {
    statements;
    ...
}
```

This executes the enclosed statements as long as the associated
condition is true.   

## 5. Functions

Functions are defined using the `func` keyword as follows:

```
func fib(n int) int {
    if (n <= 2) {
       return 1;
    } else {
       return fib(n-1) + fib(n-2);
    }
}
```

Functions must specify types for the input parameters and return value
as shown.  A function can have multiple input parameters. For example:

```
func add(x int, y int) int {
    return x + y;
}
```

When calling a function, all function arguments are fully evaluated,
left-to-right prior to making the function call.  That is,
in a call such as `foo(a, b, c)`, the arguments `a`, `b`, and `c` are
fully evaluated to a value first. This is known as "applicative
evaluation order" or "eager evaluation."

All arguments are passed to a function by value--meaning that they are
effectively copies of the input.

Wabbit does NOT have higher-order functions.  Functions are not
special types nor can they be passed around as objects.  The only
way to refer to a function is by its name.

## 6.  Scoping rules

Wabbit uses lexical scoping to manage names. Declarations defined
outside of a function are globally visible to the entire
program. Declarations inside a function are local and are not visible to
any other part of a program except for code in the same function.  For
example:

```
var a int;     // Global variable

func foo(b int) int {
    var c int;          // Local variable
    ...
}
```

Wabbit also makes use of so-called "block-scope" where variables declared
inside any block of code enclosed by curly braces (`{` ... `}`) are only
visible inside that block.  For example:

```
func bar(a int, b int) int {
    if a > b {
        var t = b;   // Block scope variable
        b = a;
        a = t;
    }
    print t;             // Error: t not defined (not in scope)
    return a;   
}
```

Nested function definitions (a function defined inside another
function) are NOT supported.  Moreover, function definitions may only
appear at the top-level, not within a nested code block.

## 7.  Execution model

Programs execute much like a script, running top-to-bottom until there are no more
statements to execute.   If there are functions defined, you must add extra steps
to invoke those functions.   For example:

```
func fact(n int) int {
     if n == 0 {
         return 1;
     } else {
         return n * fact(n-1);
     }
}

func run() int {
    var n = 1;
    while n < 10 {
        print fact(n);
        n = n + 1;
    }
    return 0;
}

run();
```

## 8. Printing

The built-in `print value` operation can be used for debugging
output.  It prints the value of any type given to it.  Values are
normally printed on separate lines.  However, if you print a single
character value, it is printed with no line break.

`print` is an example of a polymorphic operation in that it 
works on any kind of data.  This is different than how functions
work--where a matching datatype must be given.

## 9. Formal Grammar

The following grammar is a formal description of Wabbit syntax written
as a PEG (Parsing Expression Grammar). Tokens are specified in ALLCAPS
and are assumed to be returned by the tokenizer.  In this
specification, the following syntax is used:

```
{ symbols }   --> Zero or more repetitions of symbols
[ symbols ]   --> Zero or one occurences of symbols (optional)
( symbols )   --> Grouping
sym1 / sym2   --> First match of sym1 or sym2.
```

A program consists of zero or more statements followed by the end-of-file (EOF).
Here is the grammar:

```
program : statements EOF

statements : { statement }

statement : print_statement
          / variable_definition
          / func_definition
          / if_statement
          / while_statement
          / return_statement
          / assignment_statement
          / expression SEMI

print_statement : PRINT expression SEMI

variable_definition : VAR NAME ASSIGN expression SEMI
                    / VAR NAME type SEMI

func_definition : FUNC NAME LPAREN [ parameters ] RPAREN type LBRACE statements RBRACE

parameters : parameter { COMMA parameter }

parameter  : NAME type 

if_statement : IF relation LBRACE statements RBRACE [ ELSE LBRACE statements RBRACE ]

while_statement : WHILE relation LBRACE statements RBRACE

return_statement : RETURN expression SEMI

assignment_statement : NAME ASSIGN expression SEMI

expression : term PLUS term
           / term MINUS term
           / term TIMES term
           / term DIVIDE TERM
           / term

relation : expression LT expression
         / expression LE expression
         / expression GT expression
         / expression GE expression
         / expression EQ expression
         / expression NE expression      

term : INTEGER
     / FLOAT
     / CHAR
     / NAME LPAREN [ arguments ] RPAREN
     / NAME
     / LPAREN expression RPAREN
     / MINUS term
 
exprlist : expression { COMMA expression }

type      : NAME
```


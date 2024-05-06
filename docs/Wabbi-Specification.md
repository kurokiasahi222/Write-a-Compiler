# Wabbi

The "Wabbi" language is an enhanced version of the "Wab" language
that adds more operators, a few additional statements, and makes
a few enhancements to existing features.  Think of it as trying
to make a more proper programming language.

## 1. Types

Wabbi only supports integers. Therefore all math operators should
assume integers as before.

## 2. Operators

The `+`, `-`, `*`, and `/` operators are supported.  In addition, 
unary negation is provided.  Thus, these are all valid:

```
var x = 10;
var y = 3;

print x + y;    // 13
print x - y;    // 7
print x * y;    // 30
print x / y;    // 3
print -x;       // -10
```

The division operator truncates the result so `10/3` is `3`.

Wabbi retains the restriction that the operators only operate on pairs of
values.  So, if you want to write a more complex expression, you need to
use parentheses.  For example:

```
print (x + y) + 3;
```

## 3. Relations

The following relational operators are now supported.

```
x < y
x <= y
x > y
x >= y
x == y
x != y
```

As before, relations may only be used within the test of an `if` or
`while` statement.   They may not be mixed with ordinary expressions.

## 4. Optional Else

The `else` part of an if-statement is now optional. So, you can write
code like this:

```
if x < 0 {
   ...
}
```

## 5. Optional Variable Value

Variables can be declared without an initializer.  If missing, assume the
initial value is 0.

```
var x;

print x;    // Prints 0
```

## 6. Zero-argument functions

Functions can now take no arguments. For example:

```
func f() {
    return 42;
}

print f();
```

## 7. Isolated Expressions

Isolated expressions appearing as a statement are allowed.  The
expression evaluates, but the value is disregarded.  The primary use
is writing functions that print things. For example:

```
func printval(x) {
     print x;
}

printval(10);
```

## 8. Formal Syntax

The following grammar is a description of Wabbi syntax written as a PEG
(Parsing Expression Grammar). Tokens are specified in ALLCAPS and are
assumed to be returned by the tokenizer.  In this specification, the
following syntax is used:

```
{ e }   --> Zero or more repetitions of e.
e1 / e2 --> First match of e1 or e2.
[ e ]   --> Optional expression
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
          / expr_statement

print_statement : PRINT expression SEMI

variable_definition : VAR NAME [ ASSIGN expression ] SEMI  ; Note: [ ... ] means optional

assignment_statement : NAME ASSIGN expression SEMI

if_statement : IF relation LBRACE statements RBRACE [ ELSE LBRACE statements RBRACE ]

while_statement : WHILE relation LBRACE statements RBRACE

func_definition : FUNC NAME LPAREN [ parameters ] RPAREN LBRACE statements RBRACE

parameters : NAME { COMMA NAME }

return_statement : RETURN expression SEMI

expr_statement : expression SEMI

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
     / NAME LPAREN [ arguments ] RPAREN
     / NAME
     / LPAREN expression RPAREN
     / MINUS term

arguments : expression { COMMA expression }
```

The following tokens are defined:

```
NAME    = [a-zA-Z][a-zA-Z0-9]*
INTEGER = [0-9]+
PLUS    = "+"
MINUS   = "-"
TIMES   = "*"
DIVIDE  = "/"
LT      = "<"
LE      = "<="
GT      = ">"
GE      = ">="
EQ      = "=="
NE      = "!="
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







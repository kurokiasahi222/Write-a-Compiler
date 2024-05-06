# Wabbit 1 - Understanding Types

The goal of the "wabbit" project is to add a static typing discipline to
the Wabbi language.  Types will be attached to values and checked during
compilation.  Type errors will result in a compile-time error.  Types
will also be used to guide code generation.

This document describes the problem of types at a somewhat high-level
and offers a possible starting point for coding.

## Types and Expressions

In a programming language, expressions represent values.  A value is
something concrete that can be passed around as data.  A value can be
stored in memory.  A value can be printed.

With the introduction of typing, expressions represent different
kinds of values.  For example, you might have an integer, or a
floating point number, or a textual character.   However, a key
insight is that *ALL EXPRESSIONS HAVE A TYPE*.    I've emphasized
that in ALL-CAPS to call attention to the central problem of this
project.  Typing is almost entirely about expressions.

## Type Inference

The type of a simple expression can often be inferred purely from syntax.
For example, the value `42` represents an `int` and `4.2` represents
a `float`.   The main difference being that floating point numbers
are written with a decimal point.

Types of more complex expressions can be inferred from the types of
their parts and the nature of the operation being performed.
For example, the expression `2 + 3` represents an `int`
because `2` and `3` both have type `int` and the result of adding
two `int` values is also an `int`.

Variables also have types, because variables are also assigned values.
When you write `var x = 123`, we know that `x` is an `int` because
`123` is an `int`.  The type of a variable is something that will need
to be tracked by the compiler.  Otherwise, it won't be able to figure
out the resulting type of an expression such as `x + y`.

A major part of supporting types involves bookkeeping.  Every expression
and every variable name needs to have a type attached to it.  The compiler
will need to walk the AST and make sure that the typing information is known.

## Type Specifiers

In some cases, there is no information available to understand types.
As example, consider a variable declaration like this:

```
var x;
```

What type is `x`?   We have no idea.   Similarly, consider this function:

```
func min(x, y) {
    if x < y {
        return x;
    } else {
        return y;
    }
}
```

What type is `x`? What type is `y`?  What is the result type?  We
actually have no idea!   At best, we can only say that `x` and `y`
must be comparable due to the `x < y` operation, but that's not
really enough.

To address these issues, we can use explicit type specifiers.
A type specifier explicitly gives the type in situations where it can't
otherwise be determined.   For example:

```
var x int;

func min(x int, y int) int {
    if x < y {
        return x;
    } else {
        return y;
    }
}
```

In the case of Wabbit, type specifiers are required on uninitialized
variables, function parameters, and function return values.

The problem of type-specifiers is partly one of syntax.  The syntax
of the language is extended to support the specifiers and the parser
will be need to be modified to look for them.  In addition, types
will need to be added to related parts of the AST. 

## Type Semantics

With multiple types, you need to start making decisions about the
mixing of types.  Suppose you see the expression `x + y`.  What are the
rules concerning the type of `x` and the type of `y`?   Do they
have to be the same type?  Can they be different types?   What is the
result type of the expression?

This can get very messy.  For example, what is the behavior of
integer division?   Is `4/3` an integer such as `1` or is it a floating
point number like `1.33333333333`?

Your compiler must be aware of the rules concerning types and enforce
those rules.  A type-related error message should be produced if a
violation is detected.

## Machine Types

Types play a critical role at the low-level machine level.  Integers and
floating point numbers are represented in a different way (different
data sizes, different bits).    There are different machine instructions
to perform mathematical operations.   Those instructions might also involve
different CPU registers and different memory operations.

Thus, if the compiler is generating code for an expression such as `x + y`,
the final code will different for integers than it is for
floats.

## Starting Out

To start with types, it may help to address two basic problems:

1. How do you want to represent types in the compiler?  The Wabbit language
involves types such as `int`, `float`, and `char`.  The types have
names.  How does this type information get encoded in the AST?  Do you
have a special `Type` AST node?  Or is it a string with just the type
name?  Future consideration:  programming language often have more advanced
type-related features like structs, classes, enums, pointers, arrays, etc.
Should we write our code in anticipation of future expansion?


2. How do types actually get attached to expressions?  Is it an extra
attribute that gets attached to all expression-related AST nodes?  Are
types added to expressions through some kind of wrapper class?  Are types
stored elsewhere somehow?

One possible starting point is to take your work on the Wabbi language
and to extend it to support an explicit `int` datatype.  All values in Wabbi
were already assumed to be integers so this wouldn't really change the
behavior of your existing compiler. You would just be making the `int`
part more explicit and preparing the compiler for future expansion of having
more types added to it.

Note: This part of the project is almost entirely about the AST
and addressing the problem of where type information would be stored
inside the compiler.

For early testing, you should be able to run the same tests that you
used on the earlier Wab and Wabbi projects.


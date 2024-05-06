# Compiler Project Overview

You are going to be implementing a compiler for a small imperative programming
language called "Wabbit."  Wabbit supports the following features:

- Evaluation of expressions (math)
- Integers, floats, and characters
- Assignment to variables
- Printing
- Basic control flow (if, while)
- User-defined functions

We will be writing all of the components from scratch using first-principles.
This means no outside libraries or frameworks.

## Big Picture

Compiler writing is one of the oldest areas of computer science and
involves a wide range of topics from programming languages,
algorithms, computer architecture, systems, software architecture, and
more.  Obviously, it is impossible to cover everything over the span
of a week.   Therefore, it's probably best to view the week as an
introduction to a variety of topics.

It should also be stressed that our focus is *NOT* on programming
language design.  The Wabbit language is meant to be minimalistic and
similar to common programming languages that you already use.
Growing it into a full-featured programming language would be an
entirely different course.

## A Taste of Wabbit

Here is a sample Wabbit program that computes the ever-so-useful
Fibonacci numbers:

```
// fib.wb -  Compute fibonacci numbers

// A function declaration
func fibonacci(n int) int {
    if n > 1 {              // Conditionals
        return fibonacci(n-1) + fibonacci(n-2);
    } else {
        return 1;
    }
}

var n int = 0;            // Variable declaration
while n < 30 {            // Looping (while)
    print fibonacci(n);   // Printing
    n = n + 1;            // Assignment
}
```

## Wabbit Language Specification

[Wabbit Language Reference](Wabbit-Specification.md) contains an official specification for the language.

## Project Organization

We are going to approach the project by implementing three programming languages, each
more complicated than the last.   The goal is to incrementally build Wabbit in manageable
parts.   

### Wab

This is an extremely minimal language that implements the core of Wabbit. It
only supports integers and only has a limited set of operators.  The goal of
Wab is to implement all of the core pieces of the compiler project including
parsing and code generation.

### Wabbi

Wabbi is an "improved" version of Wab that adds more operations and fills
in a number of gaps to make a more fully featured programming language.  However,
it still only supports integers.   To complete this, you will have to revisit
most parts of the compiler and make minor changes.   So, it's a good
review of everything.

### Wabbit

This is a full version of the Wabbit language.  The main change is the
introduction of a type system that includes floating point numbers and
characters.  This involves taking the earlier work and putting a
typing discipline on it.     Adding types will require a certain
amount of thinking and refactoring. Expect some difficulty. 

## Implementation Strategy

Classically, compilers are organized into well-defined "passes" that perform a
specific task.  For example:

- Tokenizing
- Parsing
- Type Checking
- Code Generation

There is some design debate concerning the size and scope of these passes.
For example, is it better to have a small number of large passes?
Or is it better to have a large number of small passes?

In our project, we will be writing what's known as a "nano-pass"
compiler.  This is a compiler that has a large number of very focused
passes.  Each pass will either perform some kind of error checking or
make a small data transformation to "simplify" the program in some
way.  Constructing a compiler in this way often makes it more
tractable to develop, debug, and test.

# Write a Compiler : May 13-17, 2024

Hello! This is the course project repo for the "Write a Compiler"
course.  This project will serve as the central point of discussion, code
sharing, debugging, and other matters related to the compiler project.

Although each person will work on their own compiler, it is requested
that all participants work from this central project, but in a separate
branch.   You'll perform these setup steps:

    bash % git clone https://github.com/dabeaz-course/compilers_2024_05
    bash % cd compilers_2024_05
    bash % git checkout -b yourname
    bash % git push -u origin yourname

There are a couple of thoughts on this approach. First, it makes it
easier for me to look at your code and answer questions (you can 
point me at your code, raise an issue, etc.).   It also makes it easier
for everyone else to look at your code and to get ideas.  Writing a
compiler is difficult. Everyone is going to have different ideas about
the implementation, testing, and other matters.  By having all of the
code in one place and in different branches, it will be better.

## Instructor Solution

I will also be coding the compiler from scratch.  You can follow along by
looking in the "dabeaz" branch of the GitHub repo.

## Live Session 

The course is conducted live from 09:30 to 17:30 US Central Daylight Time/Chicago (UTC-5:00)
on Zoom.  The meeting will be open about 30 minutes prior
to the start time. Meeting details are as follows:

Join Zoom Meeting
https://us02web.zoom.us/j/82028132129?pwd=aUZwNjAwVjBVT0JOTjVLZVBHMHdkdz09

Meeting ID: 820 2813 2129
Passcode: 195233

## Chat

The preferred place for technical discussion/chat for the course will be [GitHub
discussions](https://github.com/dabeaz-course/compilers_2024_05/discussions).
Zoom chat can be used for quick questions.

## Course Requirements

You are free to write the compiler in any language that you wish.
However, for later code generation, you will minimally need the
following tools installed:

* The clang C/C++ compiler (for LLVM)
* Node-JS and WABT (for WebAssembly)

Solution code will be written in plain Python.  All code is written
from scratch using no third-party libraries.  As such, it should be
possible to translate the concepts to other languages.

**CAUTION:** If you intend to implement the compiler in a statically
typed language (e.g., Rust, C++, C#, Go, etc.), it is STRONGLY advised
that you investigate techniques for representing abstract syntax trees
(ASTs) prior to the course start.  This is how we start the project
and it can be easy to get derailed by technical details of AST
representation if you've never looked at it before.  Given the choice,
I think you're better off using a dynamic language (or at least one
with automatic garbage collection) for this project.

## Preparation

To prepare for writing a compiler, there are certain background topics
that you might want to review.  First, as a general overview, you
might look at the first part of the excellent book [Crafting Interpreters](https://craftinginterpreters.com).
Writing a compiler is similar to an interpreter--especially in terms of the data
structures involved. As for specific topics, here
are some important facets of the project:

* Trees and recursion.  Most of the data structures in a compiler are
  based on trees and recursively defined data structures. As such,
  much of the data processing also involves recursive functions.
  Recursion is often not a part of day-to-day coding so it's something
  that you might want to review in advance.  I strongly advise
  working the [Warmup Exercise](docs/Warmup-Exercises.md) to see examples of
  the kind of recursion used in a compilers project.  If you are
  using a statically typed language (e.g., Rust, C++, etc.), it
  is STRONGLY advised that you review techniques for representing trees.

* Computer architecture.  A compiler translates high-level programs
  into low-level "machine code" that's typically based on the von Neumann architecture
  (https://en.wikipedia.org/wiki/Von_Neumann_architecture).  I don't
  assume prior experience writing machine language, but you should
  know that computers work by executing simple arithmetic instructions,
  loading and storing values from memory, and making "goto" jumps.

* Programming language semantics.  Writing a compiler also means that
  you're implementing a programming language.  That means knowing a
  lot of the fine details about how programming languages work. This
  includes rules for variables, expression evaluation (e.g., precedence),
  function calls, control flow, type checking, and other matters.
  In this course, we're creating a very simple language.  However,
  there are still many opportunities for confusion.  One such area
  is understanding the difference between an "expression" and a
  "statement."  In Python, that can be studied further by exploring
  the difference between the `eval()` and the `exec()` built-in
  functions.  Why are these functions different?

* Working interactively from the command line. The compiler project
  is a command-line based application.  You should be able to navigate
  the file-system, write command-line based scripts, and interactively
  debug programs from the command-line.   The `python -i` option
  may be especially useful.

* String processing. Part of the project involves writing a
  parser.  This involves a certain amount of text processing.
  You should be comfortable iterating over characters, splitting
  strings apart, and performing other common string operations.
  Knowing things like regular expressions might help, but aren't
  really needed for the project.

## Warmup work

It is requested that you work on the following project PRIOR to
the first day of the class.   Although not strictly required, this
will make the project easier.

* [Warmup Exercises](docs/Warmup-Exercises.md)
* [The Metal](docs/The_Metal.md)

## The Project

More information on the project can be found in the [docs](docs/README.md)
directory.

## Live Session Recordings

Videos from the live sessions will be posted here.

**Day 1**

* [Morning](https://vimeo.com/945986973/cf55e9bb28)
* [Afternoon](https://vimeo.com/945986973/cf55e9bb28)
* [Chat](chats/05_13_chat.txt)




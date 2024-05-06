# Preparation Project : The Metal

If possible, you should try to complete this project prior to the
first day of class.  At the very least, it will make sure your setup
works.

## Part 0 - Setup

Before beginning, make sure you're working on your own branch of the
GitHub repo.

```
bash $ git checkout -b yourname
bash $ git push -u origin yourname
```

You will also need to make sure you have the clang C/C++ compiler installed.
More details at [https://llvm.org](https://llvm.org).   Note: If using
a Mac, clang is already installed with the Apple developer tools.

## Part 1 - Running a Compiler

As programmers, we're all used to writing code in a high-level
language like Python, C, Rust, Go, etc.  However, ultimately our computer
programs have to run on a CPU--a piece of hardware.  CPUs are much
more primitive.  Really, they're often not much more than a glorified
calculator with some memory.   They get programmed in "machine code."

When most programmers think about compilers, they usually think of
them as a tool that translates a high-level program into machine code.
Go to the file `metal/hello.c` and follow the instructions inside.

## Part 2 - Introducing LLVM

In the second part of this project, we'll briefly look at LLVM, a
target language used for the project.

Go to the file `metal/metal.ll` and follow the instructions inside.
Our goal is to get a small taste of what machine-level coding looks
like.  This is the kind of code that our compiler will create.

Note: You can consult the [LLVM Tutorial](LLVM-Tutorial.md) for more
detailed information on LLVM.  You probably won't need it for this
exercise, but it may be useful in later stages of the compiler project
itself.

## Part 3 - WebAssembly

In the final part of this project, you'll try a small example of
WebAssembly.   Go to the file `metal/code.wat` and follow the
instructions inside.  Mostly, this will be a test of your setup
and another example of low-level coding.

## Final note

Reminder: If you want me to be able to look at your code and answer
questions, you will need to commit your code to the repo and push your
changes upstream.

```
bash $ git push -u origin yourname
```


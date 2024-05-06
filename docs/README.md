# Write a Compiler

Various course materials, specifications, and other documents are
found here.  (Note: Until the course starts, all of this material is
subject to change). Submit questions as issues. Feel free to
fix small typos.

* [Project Overview](Compiler-Project-Overview.md)
* The [Wabbit Specification](Wabbit-Specification.md)

## Preparation Exercises (Coding Practice)

* [Warmup Exercises](Warmup-Exercises.md)

## Preliminaries

You should try to work this project prior to the first day of class.

* [The Metal](The_Metal.md)

## Part 1 : The Wab Language

In the first part, we will write a compiler for a simplified language
called [Wab](Wab-Specification.md).  The goal is to see all of the
parts of the compiler working without getting bogged down in tricky
edge cases.  Wab looks a lot like the final Wabbit language, but it's
missing a number of features that will get added later.

Program Representation and Rewriting

* [1. The Model](Wab1_The_Model.md)
* [2. The Simplifier](Wab2_The_Simplifier.md)
* [3. The Resolver](Wab3_The_Resolver.md)
* [4. The Unscripted](Wab4_The_Unscripted.md)
* [5. The Returns](Wab5_Returns.md)

Parsing:

* [6. Tokenizing](Wab6_Tokenizing.md)
* [7. Parsing](Wab7_Parsing.md)

Intermediate Code:

* [8. Generating Code for Expressions](Wab8_Expressions.md)
* [9. Generating Code for Statements](Wab9_Statements.md)
* [10. Basic Blocks](Wab10_BasicBlocks.md)
* [11. Control Flow](Wab11_ControlFlow.md)

LLVM:

* [12. LLVM Code](Wab12_LLVMCode.md)
* [13. LLVM Entry Blocks](Wab13_LLVMEntry.md)
* [14. LLVM Output Code](Wab14_LLVMFormat.md)
* [15. Runtime](Wab15_Runtime.md)

When you're done, see if you can compile a program to print factorials.
See `wab/tests/fact.wb` and `wab/tests/factre.wab`.

## Part 2 : The Wabbi Language

In this part, we're going to take the Wab language and make a bit of
improvement ("bi") to it to create the [Wabbi](Wabbi-Specification.md)
language.  This is going to make it feel a lot more like a proper
programming language.  These projects can be worked in any order. Some
are quite short.  Those marked with a (*) are optional.  Only work
those if you feel like you have the time and interest.  The "effort"
numbers represent the time it took me to implement the various
projects--view these as a rough estimate of the implementation
complexity.

* [1. Operators](Wabbi1_Operators.md)  (effort 1.0)
* [2. Optional Else](Wabbi2_OptionalElse.md) (effort 0.25)
* [3. Optional Value](Wabbi3_OptionalValue.md) (effort 0.10)
* [4. Expression Statements](Wabbi4_ExpressionStatements.md) (effort: 0.35)
* [5. Line Numbers*](Wabbi5_LineNumbers.md) (effort: 0.35)
* [6. A User Error*](Wabbi6_UserError.md) (effort: 0.25)
* [7. Braces*](Wabbi7_Braces.md) (effort: 0.5)
* [8. Abstractions*](Wabbi8_Abstraction.md) (effort: ????)
* [9. Web Assembly*](Wabbi9_WebAssembly.md) (effort: ????)

When you're done, see if you can compile a program to print fibonacci numbers.
See `wabbi/tests/fib.wb`. 

## Part 3 : The Wabbit Language

This part of the project attempts to implement the complete Wabbit
language by adding support for different datatypes including ints,
floats and characters.  As this potentially involves making changes
in every part of the compiler, it will test your wits as a software
engineer. It fact, it might be best to view it as challenge in refactoring.
How do you add a new "requirement" to the system without breaking
the entire universe?

Before you begin this part, you should copy your code to the `wabbit`
directory and work on it there.  You will likely break a lot of
things and it will probably be a good idea to have an old "working"
version of the compiler around.

The projects below describe the main steps involved.

* [1. Understanding Types](Wabbit1_UnderstandingTypes.md)
* [2. Type Specifiers](Wabbit2_TypeSpecifiers.md)
* [3. Type Inferrence](Wabbit3_TypeInferrence.md)
* [4. Floats](Wabbit4_Floats.md)
* [5. Characters](Wabbit5_Characters.md)

When you're done, see if you can compile a program to print a fancy
Mandelbrot set. See `wabbit/tests/mandel.wb`.

## Challenge Projects

These projects add some new features to Wabbit
and will probably stretch your brain.  They explore different "tricky"
things that you might want to add to your programming language as it gets
big.  All of these are optional.

* [1. For Loops](Challenge1_For.md)
* [2. Inferred Return](Challenge2_InferredReturn.md)
* [3. Short Circuit](Challenge3_ShortCircuit.md)
* [4. Break/Continue](Challenge4_BreakContinue.md)
* [5. Operator Precedence](Challenge5_Precedence.md)

## Knowledge Base

* [LLVM Tutorial](LLVM-Tutorial.md)
* [Wasm Specification](https://webassembly.github.io/spec/core/index.html)


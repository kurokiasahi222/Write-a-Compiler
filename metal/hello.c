/* hello.c

   For this project, you will need to have the Clang C/C++ compiler installed.
   See https://llvm.org.
   
   This is a small program written in C that prints out the first n
   squares.  Your computer doesn't actually understand C programs.
   To make a program that you can run, you need to run this program
   through the C compiler to produce machine code.

   In this project, we'll briefly look at that problem.
*/

#include <stdio.h>
#include <stdlib.h>

int square(int n) {
  return n*n;
}

int main(int argc, char *argv[]) {
  int x;
  int last;
  if (argc != 2) {
    printf("Usage: %s n\n", argv[0]);
    return -1;
  }
  last = atoi(argv[1]);
  for (x = 0; x < last; x++) {
    printf("%d\n", square(x));
  }
  return 0;
}

/* -----------------------------------------------------------------------------
   Exercise 1: Run a Compiler

   Your first task: run the compiler on this file and execute the resulting
   program.  You'll need to type commands at the command line such as the following.

   shell % clang hello.c -o hello.exe
   shell % ./hello.exe 5
   0
   1
   4
   9
   16
   shell %
*/

/* -----------------------------------------------------------------------------
   Exercise 2 - View the Assembly Code

   To see the resulting machine code, represented in assembly, run the
   compiler with the -S option.  For example:

   shell % clang -S hello.c
   shell % cat hello.s
   ... look at the assembly output ...

*/

/* -----------------------------------------------------------------------------
   Exercise 3 - Try a different compiler

   Take the above C code and paste it into Compiler Explorer at
   https://godbolt.org.   Try compiling with the gcc compiler.
   Compare the output with the code produced in Exercise 2.
   Try changing the target processor to something else and look at the
   output.  The machine code for every CPU is different.
*/

/* -----------------------------------------------------------------------------
   Exercise 4 - Direct modification of the assembly code. (Optional)

   In Exercise 2, you created an assembly file `hello.s`.   Copy this file
   to a new file titled `sumsquare.s`.   By looking at the file, making a few
   educated guesses, and possibly a bit of internet searching, can you
   modify the program to print the sum of squares instead?

   Note: To do this, you'll need to pick a CPU register in which to hold the
   accumulated sum.   You'll modify the loop to add values to the sum instead
   of printing.  You'll move printing to after the loop.
*/

   
   

  

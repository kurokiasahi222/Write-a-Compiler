# Wabbit 5 - Characters

In this project, you will add support for a "char" datatype to
Wabbit.   

First, you need to modify the parser to recognize `char` literals:

```
print 'a';
var newline = '\n';
```

Second, you need to make sure `char` can be used as a type-specifier
on variables and functions. 

Finally, you'll modify code generation to handle character
related types.  This will mainly concern the behavior of the `print`
statement. 

## Character Representation

The first problem with characters concerns their representation.
You should probably treat them as a special case of integers
For example, characters can be internally represented
as an integer character code.  As an example, the character `'a'`
can be represented by its ASCII code of 97.

This will mostly work everywhere except for printing.  When you print
a character, you need to print the character itself, not its integer
code.

## Character Printing

When printing characters, they are printed without any newline.
You'll need to write a dedicated runtime function for this.  For
example:

```
// runtime.c
#include <stdio.h>

int _print_char(int c) {
    printf("%c", c);
    return 0;
}
```

The LLVM code generator should use this to implement the `print`
functionality.

## Type Checking

Wabbit does not support any operations on characters other than
printing.  So, an expression such as `x + y` involving characters
is illegal.   

For the purposes of this project, you can assume that all input
programs are correctly typed. 

## Testing

The file `wabbit/tests/char.wb` has a test program you
can try to verify support for characters.

The file `tests/wabbit/mandel.wb` has a more interesting
program that makes use of both floats and characters.


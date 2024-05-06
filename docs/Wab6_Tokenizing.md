# Wab 6 - Tokenizing

This project starts the process of building a parser that can take
Wab source text and turn it into the data model you created in
Project 1.   

## Overview

When a program is presented to a compiler, it is usually given in the
form of a text file.  A text file consists of raw characters.  The
contents would be read into a text string:

```
source = "print 123 + xy;"
```

Text strings look like arrays or lists of individual characters.
Conceptually, it's like this:

```
source = ['p','r','i','n','t',' ','1','2','3',' ','+','x','y',';']
```

This representation is inconvenient--it would be much easier to work
with more complete words.  For example:

```
source = ['print', '123', '+', 'xy', ';']
```

An even better representation includes additional information to
indicate the type of text that got matched.  For example:

```
source = [('PRINT', 'print'), ('INTEGER', '123'), ('PLUS', '+'),
          ('NAME', 'xy'), ('SEMI', ';') ]
```

Recognizing patterns and breaking up the input text in this way is the
role of a tokenizer.  It is usually the first step of compilation.

## Your Task

Your task is to write the tokenizer for Wab.  Create a file `tokenizer.py`
(WARNING: DO NOT CALL THE FILE `tokenize.py`. You will break Python).
In this file, define a class that represents a `Token`.
A token minimally has both a type and a value. For example:

```
from dataclasses import dataclass

@dataclass
class Token:
    toktype : str
    tokvalue : str
```

Next, you need to write a `tokenize()` function that turns text strings into a
sequence of tokens.

```
def tokenize(text : str) -> list[Token]:
    ...
```

For example:

```
>>> tokenize('print 123 + xy;')
[ Token(toktype='PRINT', tokvalue='print'),
  Token(toktype='INTEGER', tokvalue='123'),
  Token(toktype='PLUS', tokvalue='+'),
  Token(toktype='NAME', tokvalue='xy'),
  Token(toktype='SEMI', tokvalue=';')]
>>>
```

## The Wab Specification

The following specification lists all of the token types that are used by
Wab:

```
Reserved Keywords:
    VAR     : 'var'  
    PRINT   : 'print'
    IF      : 'if'
    ELSE    : 'else'
    WHILE   : 'while'
    FUNC    : 'func'
    RETURN  : 'return'

Identifiers/Names:
    NAME    : Text starting with a letter followed by any number
              number of letters or digits.
              Examples:  'abc' 'ABC' 'abc123'

Literals:
    INTEGER :  123

Symbols and Operators:
    PLUS     : '+'
    TIMES    : '*'
    LT       : '<'
    EQ       : '=='
    ASSIGN   : '='
    SEMI     : ';'
    LPAREN   : '('
    RPAREN   : ')'
    LBRACE   : '{'
    RBRACE   : '}'
    COMMA    : ','

Comments:  To be ignored
    //             Skips the rest of the line
```

## Tips

A tokenizer works by scanning the text left-to-right, matching textual
patterns as it goes.

All of the literal symbols and operators can be matched by substring
matching--maybe even just using a lookup table.

More complex tokens such as names and numbers may require more complex
matching involving loops.  For example, to match a number, you would
first check that the current character is a digit. You would then read
all digits that immediately follow until a non-digit character is
encountered.   You could use regular-expression parsing for this,
but frankly, that's probably overkill.  

Special keywords such as `if`, `else`, `print`, and `while` can be
matched as a special case of names. For example, you would match a
generic name first and then check to see if matches a keyword.  Like
most other programming languages, special keywords in Wab can not
be used for other purposes.  For example, you can't name a variable
`if`.

A tokenizer must account for all possible text that might appear in
the input.  This includes whitespace and comments.  However, be aware
that the parser isn't interested in whitespace.  Therefore, you'll
probably have your tokenizer ignore these elements.  It is true that
certain kinds of programming tools such as code formatters might want
to know about such things.  However, that's something that can be
added later if you need it.

Don't confuse tokenizing with parsing.  A tokenizer is NOT concerned
with any part of program correctness or correct syntax.  It is merely
taking the input text and breaking it into tokens for later analysis.

## Testing

To test your tokenizer, you might be able to write some basic
unit tests. For example:

```
def test_symbols():
    assert tokenize("+ * < ==") == [
           Token('PLUS', '+'), Token('TIMES', '*'),
           Token('LT', '<'), Token('EQ', '==') ]
```

The main focus of your testing should be verifying that every possible
token that can appear in a Wab program is properly matched and
nothing more. 

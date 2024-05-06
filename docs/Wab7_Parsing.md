# Wab 7 - Parsing

In this project, we'll write a parser for Wab that allows us to build data
models directly from source code as opposed to having to build them by
hand.  Once we're done, we'll have something that makes everything a LOT
easier for testing as we'll be able to read Wab source files and turn
them into the AST.

Parsing is often one of the more complex parts of writing a compiler and
parsing theory is usually major topic in compiler books.  However, the
fundamental idea behind how parsing works is actually fairly
straightforward.  In this project, we'll write the parser by hand.
Lucky for us, Wab is fairly simple.

## The Problem

In a nutshell, parsing is a problem of pattern matching on tokens.  The Wab
language has a variety of different features.  For example, a `print`
statement:

```
print 42;
```

Or an binary expression representing addition:

```
1 + 2
```

The goal of a parser is to recognize these patterns in the token
sequence and convert those patterns into the AST/model that you
already defined.  For example:

```
Print(Integer(42))
Add(Integer(1), Integer(2))
```

## Syntax Specification

The first problem involves the specification of syntax.  How do you
precisely define the above patterns?  One approach is to use a grammar
written as a [BNF](https://en.wikipedia.org/wiki/Backus–Naur_form) or
[EBNF](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form). In a
BNF, each language feature is described by a kind of "equation."
Here's the definition of a `print` statement:

```
print_statement := PRINT expression SEMI
```

In this definition, words in all-caps such as `PRINT` and `SEMI`
represent tokens.  The lowercase `expression` refers to a pattern that
must be parsed separately and which is defined by its own equation
(not shown here).

Every feature of Wab can be described in such manner. You will find
an example if you look at the end of the [Wab
Specification](Wab-Specification.md).

## How Parsing Works at a High Level

Parsing algorithms generally work by performing a left-to-right scan
of tokens.  This scanning process is managed by keeping a variable that
stores the current token position.  This can be managed by a class such as
this:

```
class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.n = 0
```

In addition to keeping the current position, you also need a way to
advance the position. One way to do this is with an `expect()` method
that tries to match the current token against an expected type.

```
class Parser:
    def __init__(self, tokens):
        self.tokens =  tokens
        self.n = 0

    def expect(self, toktype):
        tok = self.tokens[self.n]    
        if tok.toktype == toktype:
            self.n += 1
            return tok
        else:
            raise SyntaxError(f'Expected {toktype}. Got {tok}')
```

Using `expect()`, you can write a dedicated parsing method
for each type of node in the AST.   For example:

```
class Parser:
    ...
    def parse_print(self):
        '''
        print expression ;
        '''
        self.expect('PRINT')
        value = self.parse_expression()
        self.expect('SEMI')
        return Print(value)

    def parse_return(self):
        '''
        return expression ;
        '''
        self.expect('RETURN')
        value = self.parse_expression()
        self.expect('SEMI')
        return Return(value)

    def parse_expression(self):
        ...

```

Each method will work left-to-right either matching a token directly or
descending into a lower-level parsing rule such as the
`self.parse_expression()` method being used in the `parse_print()`
method above. The final result of each parsing function is a node from
the AST.

## Step 1: Bootstrapping a Parser

One challenge is knowing how to get started without having to code
everything all at once.  We're going to take a few initial steps to help simplify
this process.

Start by hard-wiring a few "generic" parts of the parser by writing
three methods as shown here:

```
class Parser:
    ...
    def parse_statements(self):
        return [ ]

    def parse_expression(self):
        tok = self.expect('INTEGER')
        return Integer(int(tok.tokvalue))

    def parse_relop(self):
        left = self.parse_expression()
        self.expect('EQ')
        right = self.parse_expression()
        return Eq(left, right)     
    ...
```

The `parse_statements()` method returns an empty list. This
represents an empty code block like `{ }`.  The `parse_expression()`
method only recognizes a single integer value like `1`.  The
`parse_relop()` method only recognizes the `==` operator so when
combined with expressions, you can write things like `1 == 1`.

## Step 2 : Statement Parsing

With the above definitions in place, our next task is to write parsing
rules that recognize each Wab statement type.  Specifically, you
should be able to individually parse each of the following statements.

```
print 1;
var x = 1;
x = 1;
if 1 == 1 { } else { }
while 1 == 1 { }
func f(x) { }
return 1;
```

To do this, write a method dedicated to each statement.
Here is an example of the `while` statement:

```
class Parser:
    ...
    def parse_while(self):
        self.expect('WHILE')
        test = self.parse_relop()
        self.expect('LBRACE')
        body = self.parse_statements()
        self.expect('RBRACE')
        return While(test, body)
    ...
```

Now, write a short unit-test to verify that the method works.  This test will
assume the use of our hard-wired `parse_expression()`, `parse_statements()`, and
`parse_relop()` methods so the code will be syntactically correct, but look
rather primitive as far as programs go.

```
p = Parser(tokenize("while 1 == 1 { }"))
assert p.parse_while() == While(Eq(Integer(1), Integer(1)), [])
```

**Suggestion** For parsing function definitions, start out by assuming that
functions take only a single argument.  For example:

```
class Parser:
    ...
    def parse_function(self):
        self.expect('FUNC')
        nametok = self.expect('NAME')
        name = nametok.tokvalue
        self.expect('LPAREN')
        parmtok = self.expect('NAME')   # Temporary hack (later expand to multiple)
        parms = [ parmtok.tokvalue ]
        self.expect('RPAREN')
        self.expect('LBRACE')
        body = self.parse_statements()
        self.expect('RBRACE')
        return Function(name, parms, body)
    ...
```

When you're done, you should have seven methods for the seven different Wab
statements and seven unit tests.

## Step 3 : Generic Statements

Your next task is to write a generic statement parsing method `parse_statement()`
that parses any valid Wab statement.

```
class Parser:
    ...
    def parse_statement(self):
        ...
```

To do this, you need some way to distinguish between statements.  There are two
approaches you can take.  First, you can "peek" ahead at the input token to
decide what to do next:

```
class Parser:
    ...
    # Look at the next token without consuming it
    def peek(self, toktype):
        return self.tokens[self.n].toktype == toktype

    def parse_statement(self):
        if self.peek('PRINT'):
            return self.parse_print()
        elif self.peek('IF'):
            return self.parse_if()
        elif self.peek('WHILE'):
            return self.parse_while()
        elif self.peek('VAR'):
            return self.parse_variable()

        # More cases here ...
        
        else:
            raise SyntaxError("Expected a statement")
```

This approach is called "predictive parsing." The current token
predicts what is coming next.  Most parsers work in this way. One
limitation, however, is that looking at a single token might not be
enough to predict what is being parsed.  That is not the case for Wab
however.

The other way to solve the problem is to simply "try it" combined with
some error recovery and backtracking.

```
class Parser:
    ...
    def parse_statement(self):
        start = self.n
        try:
            return self.parse_print()
        except SyntaxError:
            self.n = start     # Backtrack
        try:
            return self.parse_if()
        except SyntaxError:
            self.n = start     # Backtrack

        # More cases here ...
        
        raise SyntaxError("Expected a statement")
```

This approach is the basis of so-called "PEG Parsers."   Python switched to such an
approach in version 3.10.  This approach can be applied to much more complex grammars.
However, there are potential performance downsides due to all of the backtracking.
This can be solved, but it often involves additional "hacks."

You need to pick one of these approaches and implement `parse_statement()`.
To test, change all of your prior unit tests to use `parse_statement()`.  For example:

```
p = Parser(tokenize("while 1 == 1 { }"))
assert p.parse_statement() == While(Eq(Integer(1), Integer(1)), [])

p = Parser(tokenize("print 1;"))
assert p.parse_statement() == Print(Integer(1))
```

Again, there are only seven statement types in Wab. The `parse_statement()`
method should recognize all of them.

## Step 4 : Multiple Statements

Your next step is to fix the `parse_statements()` method by having it
repeatedly called `parse_statement()`.  For example:

```
class Parser:
    ...
    def parse_statements(self):
        statements = [ ]
        while ...:      #  How do you get out???
            statements.append(self.parse_statement())
        return statements
```

The challenge here is determining when to break out of the loop (the `...`).
Clearly you don't loop forever.    To solve this problem, think about places in
the Wab syntax where multiple statements can appear.   Is there any kind of
token or feature of the syntax that would clearly indicate the "end" of statements?

Also, handling "end of file" is an edge case that you will have to consider.
Otherwise, your parser might "fall off" the end of the source file with
an error when it runs out of tokens and there are no more statements.

To test this portion, you could make a more complex test case:

```
p = Parser(tokenize("print 1; while 1==1 { print 2; }"))
assert p.parse_statements() == [
    Print(Integer(1)),
    While(Eq(Integer(1), Integer(1)), [ Print(Integer(2)) ])
    ]
```

A similar technique can be used to parse multiple function parameter names.
Modify your `parse_function()` method so that multiple parameter names
can be properly handled.  For example:

```
p = Parser(tokenize("func f(x, y, z) { return 1; }"))
assert p.parse_statements() == [
    Function('f', ['x','y','z'], [ Return(Integer(1)) ])
    ]
```

## Step 5 : Values

Expressions in Wab are formed from terms.  A term can be a number like `1`,
a name like `xyz`, a parenthesized expression like `(1)`, or a
function call like `f(x,y,z)`.

Your task is to write a generic `parse_term()` method that recognizes any
of these possibilities and returns an appropriate AST node.

When you're done, change the `parse_expression()` method to call `parse_term()`.
For example:

```
class Parser:
    ...
    def parse_expression(self):
        return self.parse_term()

    def parse_term(self):
        ...
        # Parse a number, name, (), or f(x, y, z)
        ...
```

Hint: the `parse_term()` method will need to use the same general technique
that `parse_statement()` used to decide what it is parsing (i.e., looking ahead
at the token or backtracking).

Note: Parsing function calls will require you to parsing multiple
arguments.   This will be somewhat similar to parsing multiple statements
or multiple function parameter names. 

For testing, you should be able to incorporate more complex cases into
your unit tests.

```
p = Parser(tokenize("print 1; print xyz; print (2); print f(1,x,2);"))
assert p.parse_statements() == [
    Print(Integer(1)),
    Print(Name('xyz')),
    Print(Integer(2)),
    Print(Application('f', [Integer(1), Name('x'), Integer(2)]))
    ]
```

## Step 6 : Operators

Modify the `parse_expression()` method so that it recognizes `term + term` and `term * term`
in addition to a singular `term`.  Hint: After parsing the first term, the parser can
peek ahead to see if there is an operator.  If so, it can try to parse the second term.

Modify the `parse_relop()` method so that it recognizes both `term == term` and `term < term`.

Once you've done this, you should have most of the Wab syntax working.  You should be
able to write more complex tests:

```
p = Parser(tokenize("print 1 + xyz;"))
assert p.parse_statements() == [
    Print(Add(Integer(1), Name('xyz')))
    ]
```

A reminder: Wab only allows operations between two specific terms. You are NOT allowed to
write more complex expressions like `2 + 3 * 4`.  If you want to do that, you need to add
explicit parenthesis and write `2 + (3 * 4)`. 

## Step 7 : Top-level Program

As a final step, write a top-level `parse_tokens()` method that takes
a list of tokens, parses them into a complete program.  This should return
the AST in the same form that you've been using in the rest of the compiler.
It might look something like this:

```
def parse_tokens(tokens : list[Token]) -> Program:
    p = Parser(tokens)
    return Program(p.parse_statements())
```

## Testing

The directory `tests/wab` has some sample programs that you can
compile to see if things are working.  The `program1.wb`,
`program2.wb`, `program3.wb`, and `program4.wb` files contain the
original programs that you started with on project 1.  One possible
thing to try is a test like this:

```
def parse_file(filename):
    with open(filename) as file:
         source = file.read()
    tokens = tokenize(source)
    program = parse_program(tokens)
    return program
    
# Model from Project 1
program1 = Program([
         Variable('x', Integer(10)),
         Assignment(Name('x'), Add(Name('x'), Integer(1))),
         Print(Add(Mul(Integer(23), Integer(45)), Name('x')))
         ])

parsed_program1 = parse_file('tests/program1.wb')
assert program1 == parsed_program1, parsed_program1
```

Do this for all four programs.

You may also want to think about writing a more general purpose
`compile.py` script that can read a filename from the command line,
parse the file into the AST, and process the resulting program
through all of the compiler passes written so far.

The programs `tests/fact.wb` and `tests/factre.wb` provide 
more complex tests that you can try.  See if you can parse these
files and process the resulting AST through all of your earlier
compiler passes.

## Hints

Parsing can potentially be a very complex problem depending on the
syntax of the language being passed.  Wab is intentionally designed to
be very straightforward to parse.  Every feature of the language can
be parsed using a basic left-to-right rule and token peek-ahead as shown.
If you find yourself coding crazy "hacks", you may want to step back
and rethink your approach.

If you have read about parsing before, you may have encountered a
lengthy discussion about math operator precedence and associativity
(for example, how to properly parse complex expressions like `2 + 3*x*y + 7`).
Wab does *not* have this issue because it only allows
operators to have two operands.  Thus, `2 + x` is legal, but `2 + x * y` is not.
For complicated expressions, you must include explicit parentheses and write
something like `2 + (x * y)`.  This restriction makes all precedence
and associativity handling explicit in the syntax.
















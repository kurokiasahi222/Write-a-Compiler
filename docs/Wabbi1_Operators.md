# Wabbi 1 - Operators

In this project, you'll implement a more complete set of mathematical operators.
This is mostly an expansion of code that you have already written.

## Binary Operations

The following binary operators accept and return integers.

```
x + y      (already implemented)
x - y
x * y      (already implemented)
x / y
```

## Unary Operations

```
-x 
```

The unary negation operation can be used as a term. So code like this is
legal:

```
print -2 + -x;
print -(-x * y);
print --x;
```

The negation operation only applies to a single term, not an entire expression. Be
careful in how you handle the following:

```
print -3 + 4;     // Should output 1, NOT -7
```

A common mistake is to parse `-3 + 4` as `-(3 + 4)`.  That is NOT what you want.

## Relational Operations

The following relational operators may be used with `if` and `while`
loops.   It is NOT legal to use these in ordinary mathematical calculations.

```
x < y
x <= y
x > y
x >= y
x == y
x != y
```

## LLVM Code Generation

The following reference can be used for LLVM instruction generation:

```
left + right          %result = add i32 %left, %right
left - right          %result = sub i32 %left, %right
left * right          %result = mul i32 %left, %right
left / right          %result = sdiv i32 %left, %right
left < right          %result = icmp slt i32 %left, %right
left <= right         %result = icmp sle i32 %left, %right
left > right          %result = icmp sgt i32 %left, %right
left >= right         %result = icmp sge i32 %left, %right
left == right         %result = icmp eq i32 %left, %right
left != right         %result = icmp ne i32 %left, %right
-x                    %result = sub i32 0, %x
```

## How to Proceed

Implementing this project will mostly involve the parser, AST,  and code generation
parts of the compiler. I suggest working on it end-to-end as follows:

* Add the new operator tokens to the tokenizer.  Please see the
  [Wabbi Specification](Wabbi-Specification.md) for the token names.
* Add new operator nodes to the AST.
* Add new parsing rules for the operators. 
* Patch the code formatter, resolver and other necessary parts to understand the new operators.
* Implement final code generation with LLVM.

The negation operator `-x` is something that has not been encountered before.
This is a unary operator.  A common mistake is to forget about it and to have
the compiler crash when it's encountered.  A hint:  Perhaps you could make
a compiler stage that changes the unary operator into a binary operator.
For example, rewriting `-x` as `0 - x`.

A lot of this work will be highly repetitive and "cut-paste" coding.
Most of the operators are handled in exactly the same way except
for very minor details.

## Tips and Reminders

A reminder that mathematical operators can only appear in pairs.
Writing `x + y` is allowed but writing `x + y + z` is not.  Use
parentheses to write `(x + y) + z` if you need to operate on three
values.

Also, all mathematical operations continue to be integers.
Relational operations are a special case that are only allowed
in the test for `if` and `while` statements.

## Testing

The files `wabbi/tests/operators.wb`, `wabbit/tests/relations.wb`, and
`wabbit/tests/unary.wb` are test programs you can try to see if things
are working.





# Wabbit 4 - Floats

In this project, you will add a "float" datatype to Wabbit.  First,
you'll modify Wabbit to recognize `float` literals:

```
var x = 12345;    // int
var y = 12.345;   // float
```

Second, you'll allow `int` and `float` type specifiers on variables
and functions. For example:

```
func square(x int) int {
    return x*x;
}

func fsquare(x float) float {
    return x*x;
}
```

Finally, you'll modify code generation to recognize and emit
float-related machine instructions.

## Code Generation

Integers and floats are not stored in the same way at the machine
level.  Moreover, the low-level machine instructions for manipulating
floats are different.  Here is a quick reference to the LLVM
instructions related to floats:

```
Operator           LLVM Code
--------------     -----------------------------------------
left + right       {result} = fadd double {left}, {right}
left - right       {result} = fsub double {left}, {right}
left * right       {result} = fmul double {left}, {right}
left / right       {result} = fdiv double {left}, {right}
left < right       {result} = fcmp olt double {left}, {right}
left <= right      {result} = fcmp ole double {left}, {right}
left > right       {result} = fcmp ogt double {left}, {right}
left >= right      {result} = fcmp oge double {left}, {right}
left == right      {result} = fcmp oeq double {left}, {right}
left != right      {result} = fcmp one double {left}, {right}
```

The `{left}`, `{right}`, and `{result}` placeholders need
to be filled in just like you did for generating integer
instructions.

Memory operations will need to be modified to incorporate
the type.  For the `float` type, they will look like this:

```
%{name} = alloca double                       ; local name float;
{result} = load double, double* %{name}       ; result = local[name]
store double {value}, double* %{name}         ; local[name] = value
{result} = load double, double* @{name}       ; result = global[name]
store double {value}, double* @{name}         ; global[name] = value
```

To print a floating point number, you'll need to add a new runtime
function to the LLVM generator and use it to produce output.

```
// runtime.c
#include <stdio.h>

int _print_float(double x) {
    printf("%lf\n", x);
    return 0;
}
```

## The Headache of Generic Operations

A headache in this project concerns the mixing of types and
handling of generic operations.  Consider the `print` statement.

```
print x;
```

`print` is supposed to work on any `x`. However, the code that gets
generated will vary depending on its type.  This implies that the type
needs to be known during code generation.  If you've been properly
attaching the type to expressions, you should have it though!

## Other Odds and Ends

The introduction of a `float` type is unlikely to require major changes
to most of the intermediate parts of the compiler. However, you will need to make some
minor changes to account for the new float literal object created by
the parser.  If you want features such as constant folding to work, you'll
also need to add a bit of extra code for it.

## Advice on How to Proceed

There are many parts to getting floats to work.  I suggest taking it in
small parts.   First, try to get printing of simple numbers to work:

```
print 2;
print 3.5;
```

Next, see if you can print expressions:

```
print 2 + 3;
print 2.3 + 4.5;
```

Finally, work up to variables:

```
var x = 2;
var y = 3.5;

print x + 10;
print y + 5.5;
```

Variables may involve the most work due to complexity surrounding variable
names.  When a name like `x` is referenced, you'll need to know what type it is.
So, some kind of extra metadata needs to be maintained somewhere. 

## Testing

The file `wabbit/tests/floats.wb` has a test program you
can try to verify the floating point operations.

If you want to try a more advanced program, you can try
`wabbit/tests/sqrt.wb`.


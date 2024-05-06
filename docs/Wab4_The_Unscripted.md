# Wab 4 - The Unscripted

Wab programs execute in a top-to-bottom manner a lot like a script.  Statements
can execute at the top-level or in a function.   Here is
an example:

```
var v = 4 + 5;

func square(x) {
    var r = x * x;
    return r;
}

var result = square(v);
print result;
```

From an organizational perspective, all of the free-floating top-level
statements are a little weird.  It is much more proper for all code to
be defined in a function (even in a scripting language like Python,
it's a recommended "good practice").  In this project, you'll fix this by rewriting
all of the top-level statements as a function called `main()`.

## Your Task

Your task is as follows.  Given the above program, you will first rewrite
it using the compiler stages described in Project 2 and 3. This will
produce a program like this:

```
global v;
global[v] = 9;

func square(x) {
    local r;
    local[r] = local[x] * local[x];
    return local[r];
}

global result;
global[result] = square(global[v]);
print global[result];
```

You will now run this program through an "unscript" stage that takes
all of the top-level statements and puts them into a `main()` function
at the end. This will make the final program look like this:

```
global v

func square(x) {
    local r;
    local[r] = local[x] * local[x];
    return local[r];
}

global result;

func main() {
    global[v] = 9;
    global[result] = square(global[v]);
    print global[result];
}
```

In the final code, the only statements appearing at the top-level are global
variable declarations and function definitions.  NO other statements should appear.
Everything else got moved inside `main()`.

## How to Proceed

Make a file `unscript.py` and put a `unscript_toplevel()` function.  This
function should scan the list of statements at the top-level only.  Any
statement that is NOT a global variable declaration or a function definition
should be removed and placed into a separate list.  At the very end, create
a `main()` function and use this list as the function body.

Note: This can be implemented entirely within a single function using
a for-loop and some list manipulation.  The code should be
significantly less complicated that other simplification stages.

## Big Picture

The first four projects have been almost entirely focused on data transforms
of the input program. Just to summarize, we started with a program like this:

```
var v = 4 + 5;

func square(x) {
    var r = x * x;
    return r;
}

var result = square(v);
print result;
```

We then performed a constant folding simplification that evaluated math
expressions involving constants.  This produced the following:

```
var v = 9;

func square(x) {
    var r = x * x;
    return r;
}

var result = square(v);
print result;
```

After that, we separated variable declaration and initialization. This
produced the following program:

```
var v;
v = 9;

func square(x) {
    var r;
    r = x * x;
    return r;
}

var result;
result = square(v);
print result;
```

We then resolved the scope of variable names.  This produced the
following:

```
global v;
global[v] = 9;

func square(x) {
    local r;
    local[r] = local[x] * local[x];
    return local[r];
}

global result;
global[result] = square(global[v]);
print global[result];
```

Finally, we moved all of the top-level statements into a function
called `main()`.

```
global v

func square(x) {
    local r;
    local[r] = local[x] * local[x];
    return local[r];
}

global result;

func main() {
    global[v] = 9;
    global[result] = square(global[v]);
    print global[result];
}
```

All of this preparatory work is going to help us as we move forward into code generation.
The resulting code is not as "high level" as what we started with.  Yet, it's not entirely
"low level" either.   Think of it as a happy medium where certain features have been
simplified, yet there is still an overall program structure that's understandable.




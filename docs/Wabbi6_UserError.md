# Wabbi 6 - A User Error (Optional)

The following Python program contains a common user error.
Can you spot it?

```
# flip.py

def flip(x):
    if x = 0:
        return 1
    else:
        return 0

print(flip(0))
print(flip(1))
```

Copy this code to a Python file and run it.  Carefully observe
the specific nature of the error message.

## Your Task

Can you modify your compiler to produce a similarly helpful
error message when applied to the following code:

```
// flip.wb

func flip(x) {
    if x = 0 {
        return 1;
    } else {
        return 0;
    }
}

print flip(0);
print flip(1);
```

## Further Thought

What other kinds of common programming errors could be handled in this
way?



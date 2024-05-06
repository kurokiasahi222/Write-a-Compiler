# Wabbi 2 - Optional Else

This is a small project.  Modify your compiler so that the `else` part
of an `if` statement is optional.   For example, so you can write
code like this:

```
func abs(x) {
   if x < 0 {
      return 0 - x;
   }
   return x;
}
```

## Testing

The file `wabbi/tests/optelse.wb` has a test program.

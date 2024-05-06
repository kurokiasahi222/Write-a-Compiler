# Wabbi 8 - Abstractions (Optional)

In programming, one challenge is that of eliminating repetitive
code.  You sometimes hear the mantra "DRY" (Don't Repeat Yourself).
In writing all of our little compiler phases, you have probably noticed
a certain amount of repetition and if not repetition, at least a
certain amount of similarity.

This project is simple to describe, but open-ended to implement. Is there
any kind of commonality in the code for the various compiler phases?  If
so, is there any way to abstract that code into a common "structure" that
can be reused?   If so, can you use this to reduce the complexity of
the compiler in some way?

I'm not going to provide too many hints about how to proceed here.
However, you might consider the task of navigating the AST structure
versus specific transformations that you perform on certain AST nodes.
Can those two things be separated in some way?   Consider it
a challenge to figure out how to organize the compiler in a more
elegant manner that addresses this.








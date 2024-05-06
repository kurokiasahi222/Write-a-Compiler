; metal.ll
;
; Setup:
; ------
;   - This file requires the use of clang/LLVM (https://llvm.org)
;   - You will type the following commands at the command line to build and run
;
;       % clang metal.ll -o metal.exe
;       % ./metal.exe
;       (output follows)
;       %
;
;   - Try these steps right now.  If it fails, your setup is broken.
;
; Introduction:
; -------------
; In the first part of this project, you worked with a file `hello.c`
; that you compiled into native machine code for your machine.  Although
; you can work directly with machine code, doing so involves a LOT of
; fiddly details related to the exact CPU being used as well as other
; platform specific details.
;
; Instead of doing that, it may be easier to work at a slightly higher
; level of abstraction.   In this exercise, we're going to write some
; code in LLVM (https://llvm.org).   LLVM is an example of something known
; as "intermediate representation."  
;
; LLVM is a platform-independent "assembly code" that allows you to
; write code that works on any processor.  Although it is an
; abstraction over actual hardware, it's not too abstract. We'll be
; using it in this course to side-step differences in processor
; architectures.  That way you won't have to worry about generating
; code for a specific CPU model.
;
; You can view the LLVM for a C program by typing this command:
;
;    shell % clang -emit-llvm -S hello.c
;    shell % cat hello.ll
;    ... view the LLVM code
;
; You can view the native assembly created from LLVM by typing this command:
;
;    shell % clang -S hello.ll
;    shell % cat hello.s
;    ... view the native code
;
; LLVM is not an interpreter like Python, nor does it run a virtual
; machine like Java.  When you compile LLVM, it turns into native
; machine code that runs directly on the hardware all by itself.
;
; Note:
; -----
; This project is likely to look *VERY* different from the programming
; you are used to.  Keep in mind that the purpose of the project is
; not to become an expert on low-level programming or LLVM, but to get
; a general sense for what low-level code looks like.  The output of
; your compiler project is going to look like this.  However, the whole
; reason why we're writing a compiler is so that we can write code in
; a high-level language instead.
;
; You should be able to do the project by looking at the code and
; copying the programming style that you see.  However, it's easy to
; make small mistakes and you might have to fiddle around with it
; This is normal. Don't panic!
;
; Tip: A lot of mistakes are made around minor syntax issues with
; commas, '%' characters and so forth. Be on the lookout for that.

; -----------------------------------------------------------------------------
; Exercise 1:  The following function doubles the number x.
;

define i32 @exercise1(i32 %x)
{
    %r1 = mul i32 %x, 2
    ret i32 %r1
}

; Change its code so that it computes the value of the
; following math function instead:
;
;    exercise1(x) = 3*x*x - 6*x + 7
;
; To do this, you will use the following LLVM instructions.
;
;     %{var} = mul i32 {left}, {right}
;     %{var} = add i32 {left}, {right}
;     %{var} = sub i32 {left}, {right}
;
; In these instructions, {var}, {left}, and {right} are placeholders
; that need to be filled in with variable names such as "%r1"
; or numeric constants such as "6".
;
; A critical part of the code concerns the fact that you can only
; perform one operation at a time.  Thus, a calculation such as
; 3*x*x will need to be broken down into two steps like this:
;
;     %r1 = mul i32 3, %x       ; Compute r1 = 3*x
;     %r2 = mul i32 %r1, %x     ; Compute r2 = r1*x   (3*x*x)
;
; Also, a subtle detail about LLVM is that each operation must assign
; its result to a *uniquely* chosen variable name.  Hence the use of
; "%r2" in the second step.  If you add more steps, you should use
; names like "%r3", "%r4", "%r5", etc.

; -----------------------------------------------------------------------------
; Exercise 2:  The following function computes absolute value of x.

define i32 @exercise2(i32 %x)
{
    %result = alloca i32
    %r1 = icmp slt i32 %x, 0         ; if x < 0
    br i1 %r1, label %L1, label %L2  ; branch depending on result

L1:
    %r2 = sub i32 0, %x              ; result = 0 - x
    store i32 %r2, i32* %result      ; 
    br label %L3                     ; goto L3

L2:
    store i32 %x, i32* %result       ; result = x
    br label %L3

L3:
    %r3 = load i32, i32* %result     ; return result
    ret i32 %r3
}

; Here is some rough Python pseudocode that illustrates what it does.
;
;   def exercise2(x):
;       result = None
;       if x < 0:
;            result = 0 - x
;       else:
;            result = x
;       return result
;
; Modify the code to "clip" the value to be in the range 0 <= x <= 5 instead.
; Here's Python pseudocode illustrating the desired behavior.
;
;  def exercise2(x):
;      result = None
;      if x > 5:
;          result = 5
;      elif x < 0:
;          result = 0
;      else:
;          result = x
;      return result
;
; To do this, you will find the following LLVM instructions useful
;
;      %{loc} = alloca i32                       ; Create a new uninitialized variable location
;      %{var} = icmp slt i32 {left}, {right}     ; {var} = {left} < {right}
;      %{var} = icmp sgt i32 {left}, {right}     ; {var} = {left} > {right}
;      br i1 {cond}, label {then}, label {else}  ; Conditional branch
;      store i32 {value}, i32* {loc}             ; {loc} = {value}
;      %{var} = load i32, i32* {loc}             ; {var} = {loc} 
;
; In these instructions {var}, {loc}, {left}, {right}, {cond}, {then},
; and {else} are placeholders that need to be filled in with the
; names of variables, locations, values, or branch labels.  There are a
; number of tricky details we're ignoring, but the sample code should be
; enough of a guide to figure it out (maybe).
; 

; -----------------------------------------------------------------------------
; Exercise 3:  The following function prints a number if it's less than 10.
; The following Python code illustrates:
;
;    def exercise3(x):
;        if x < 10:
;            print(x)
;
; You task: Change the function into the equivalent of this loop:
;
;    def exercise3(x):
;        while x < 10:
;            print(x)
;            x += 1
; 
; To do this, you may need to introduce some additional labels and branch
; instructions.   One hint: You may need to introduce a variable to make
; the increment work.  Code it like this:
;
;    def exercise3(x):
;        n = x           # Create using alloc, use load/store to access
;        while n < 10:
;            print(n)
;            n += 1
;
; One other hint: Every labeled block of instructions must end with a
; branch instruction or a return.  

define void @exercise3(i32 %x)
{
    %r1 = icmp slt i32 %x, 10         ; if x < 10
    br i1 %r1, label %L1, label %L2  ; branch depending on result

L1:
    call void (i32) @printi(i32 %x)
    br label %L2

L2:
    ret void
}

; -------- DO NOT MODIFY CODE BELOW HERE

declare void @printf(i8*, ...)

; Helper function
@.format = constant [4 x i8] c"%d\0A\00"
define void @printi(i32 %x) {
    call void (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.format, i32 0, i32 0),i32 %x)
    ret void
}

define i32 @main() {
    ; ----- Exercise 1
    %r1 = call i32 (i32) @exercise1(i32 10)
    call void (i32) @printi(i32 %r1)

    ; ----- Exercise 2
    %r2 = call i32 (i32) @exercise2(i32 7)
    call void (i32) @printi(i32 %r2)

    %r3 = call i32 (i32) @exercise2(i32 -7)
    call void (i32) @printi(i32 %r3)

    %r4 = call i32 (i32) @exercise2(i32 3)
    call void (i32) @printi(i32 %r4)

    ; ----- Exercise 3
    call void (i32) @exercise3(i32 0)

    ; ----- Done
    ret i32 0
}    







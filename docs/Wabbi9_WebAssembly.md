# Wabbi 9 - Generating WebAssembly (Optional)

One possible target for your compiler is WebAssembly.  WebAssembly
follows the architecture of a stack machine.  You can
watch a [talk](https://www.youtube.com/watch?v=VUT386_GKI8) I
gave wherein I implemented a WebAssembly interpreter from scratch.

A short overview of WebAssembly follows along with some examples
that you can try before adding such features to your compiler.  

## Overview

In this project, you will generate WebAssembly, much in the same
way you generated LLVM. For this, you are going to generate output in the WebAssembly Text
format (WAT).  You can then use tools such as "wat2wasm" to convert
this to the WASM binary encoding.  Ultimately your compiler needs to
produce a file called "out.wasm" that will be loaded by the
corresponding script "test.js" (found in the `compilers/misc`
directory).

The first part of this project talks you through the process of creating
WebAssembly and getting things to run.  Consider it to be a tutorial
that you should try on your own first.

## Requirements

You will need to install some dependencies. Specifically,
a recent version of "node-js" (https://nodejs.org).  You will also need
to install "wabt" using "npm install wabt". Of particular interest is
the script "wat2wasm" found in "nodes_modules/wabt/bin/wat2wasm".

## Web Assembly Overview

WebAssembly is a stack-based architecture.  If you want to compute 2 + 3 * 4
the sequence of instructions will look something like this:

```
i32.const 2         ;; push 2
i32.const 3         ;; push 3
i32.const 4         ;; push 4
i32.mul             ;; 3 * 4 -> 12
i32.add             ;; 2 + 12 -> 14
```

WebAssembly has two primitive datatypes. "i32" is a 32-bit
integer and "f64" is a 64-bit floating point number. Since Wabbi only
understands integers, we will only be working with the "i32" type.

WebAssembly code is placed into a module. Here is a template of the
format that matches up with what's required by the `misc/test.js` file:

```
;; out.wat
(module
    ;; foreign functions (imported from JavaScript)
    ;; See the file misc/test.js for their implementation.
    (import "env" "_print_int" (func $_print_int ( param i32 )))
    (func $main (export "main")
       ;; instructions go here
    )  ;; end main
    )  ;; end module
```

Text preceeded by ";;" is a comment and is not required. 

Your compiler should produce a file "out.wat".  That file needs to be
processed using the script "wat2wasm" to create "out.wasm". 
Here is how that might work:

```
bash % ./node_modules/wabt/bin/wat2wasm out.wat
bash % node test.js
... program output ...
bash %
```

Try creating an "out.wat" file by hand (copying the code above into
it), and run the "wat2wasm" and "node" commands.  You should get no
errors and no output.  This will let you know that the tool-chain is
probably working.

## "Hello World" Example

You will start out by putting further instructions into the main()
function.  Here is an example that prints "42" to the screen.

```
(func $main (export "main")
      i32.const 42
      call $_print_int
)
```

Add these instructions to out.wat and use wat2wasm to create out.wasm.
Run "node test.js" and verify that 42 gets printed to the screen.

## Mapping of Wabbit Features to Wasm

The following example shows how various wabbit features get mapped
to WebAssembly.  It is mostly straightforward--you need to produce output
that follows this general template.  Copy this to "out.wat" and experiment
with it.

```
;; out.wat
(module
    (import "env" "_print_int" (func $_print_int (param i32) (result i32)))

    ;; Global variables are declared outside of the main function here
    ;; var x int = 2 + 3;
    (global $x (mut i32) (i32.const 0))

    (func $main (export "main")
      ;; Initialization of "x" global
      i32.const 2
      i32.const 3
      i32.add
      global.set $x

      ;; print x;
      global.get $x
      call $_print_int

      ;; if x < 3 { print 1; } else { print 2;}
      global.get $x
      i32.const 3
      i32.lt_s
      if
         i32.const 1
         call $_print_int
      else
         i32.const 2
         call $_print_int
      end

      ;; while x > 0 {
      ;;    print x;
      ;;    x = x - 1;
      ;; }
      block $loop_exit
          loop $loop_test
               global.get $x
               i32.const 0
               i32.le_s   ;; Note: logic is reversed to test for loop "exit"
               br_if $loop_exit
               global.get $x
               call $_print_int
               global.get $x
               i32.const 1
               i32.sub
               global.set $x
               br $loop_test
           end
      end
    )  ;; end main
)  ;; end module
```

## Useful Instructions

### Integer operations

```
    i32.const value      ;; Constant value
    i32.add              ;; +
    i32.sub              ;; -
    i32.mul              ;; *
    i32.div_s            ;; / (signed division)
    i32.lt_s             ;; < (signed)
    i32.le_s             ;; <= (signed)
    i32.gt_s             ;; > (signed)
    i32.ge_s             ;; >= (signed)
    i32.eq               ;; ==
    i32.ne               ;; !=
    i32.and              ;; &&
    i32.or               ;; ||
    i32.xor              ;; Exclusive-OR
    drop                 ;; Discard last value
```

### Global variable get/set

```
    (global $iname (mut i32) (i32.const 0))     ;; Declare an i32
    global.get $var                             ;; Get a value (put on stack) 
    global.set $var                             ;; Set a value (store from stack)
```

### Local variable get/set

```
    (local $iname i32)                          ;; Declare an i32
    local.get $var                              ;; Get a value (put on stack) 
    local.set $var                              ;; Set a value (store from stack)
```

### Control flow

```
     if ... else ... end   ;; Conditional
     block $label ... end  ;; Code block
     loop $label ... end   ;; Loop block
     br $label             ;; Unconditional break from enclosing block/loop label
     br_if $label          ;; Conditional break from enclosing block/loop label
     call $func            ;; Call function
     return                ;; Return from function
```

Control flow in Wasm is a little strange.   It's probably better to think of it
in terms of "break" and "continue" statements from looping in a structured language.
Basically, the "br" and "br_if" instructions act like a "break" statement that
escape out of the indicated block.   For example:

```
block $a
    block $b
    ...
    br $a          ;; Jumps to (1) below --+
    ...                                    |
    end  ;; $b                             |
end ;; $a                                  |
instructions       ;; (1)   <--------------|
...
```

However, loop blocks work a bit different. With a loop block, the
"br" and "br_if" instructions jump back to the top of the loop.

```
block $a
   loop $b    ;; (1) <-----------------+
     ...                               |
     br_if $a ;; Jumps to (2) below ---|---+
     ...                               |   |
     br $b    ;; Jumps to (1) above ---+   |
     ...                                   |
   end ;; $b                               |
end ;; $a                                  |
instructions  ;; (2) <---------------------+
```

Using different combinations of "loop", "if", and "block" constructs,
you can make the program jump around.  

### Functions.

Here's how a Wabbi function maps to a WebAssembly function.  Just a reminder
than Wabbi only supports integers.

```
func add(x, y) {
     return x + y;
}
```

Corresponding Wasm

```
(func $add (export "add")
    (param $x i32)
    (param $y i32)
    (result i32)
    (local $return i32)      ;; Storage of return value
    block $return
       local.get $x
       local.get $y
       i32.add
       local.set $return     ;; Store return result
       br $return            ;; Branch to the function end
    end
    local.get $return
)
```

To call this function from elsewhere, use instructions like this.
For example, to call add(2, 3)

```
i32.const 2    ;; push arguments on stack
i32.const 3
call $add
```

## Your Task

The overall strategy here is going to be very similar to how you
inmplemented LLVM output. As with LLVM, most parts of Wabbi will
map almost directly to WebAssembly.

## Testing

If this part of the project is working, you should be able to take any
program in `wabbi/tests` and compile it to a WebAssembly file.
For example:

```
bash $ python3 wabbi.py -wasm tests/test_operators.wb
Wrote out.wasm
bash $ 
```

To test the program, you can run the `misc/test.js` program using Node.  For example:

```
bash $ node misc/test.js
... output from the program ...
bash $
```

Alternatively, you can run it in the browser.  Run a small web server
in the top-level directory like this:

```
bash $ python3 -m http.server
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

Now, click on
[http://localhost:8000/test.html](http://localhost:8000/test.html).
If it's working, you should see the program output in the browser.

## Hints

There are a lot of fiddly bits that can go wrong here. Debugging is
often difficult.  If you get no output at all, turn on the debugging
features of your browser. WebAssembly related errors are often
reported on the JavaScript console.

However, you might also find that this project is "easy."  The
"low-level" Wabbi code used to generate LLVM is actually quite close
to WebAssembly in structure.



;; code.wat
;;
;; WebAssembly is a low-level "machine" language that's somewhat similar to LLVM.  The
;; following code shows an example.  This program contains a function that computes
;; a factorial and a function that sums the first n integers (which you must write).
;;
;; -----------------------------------------------------------------------------
;; Exercise 1 - Just get it to run.
;;
;; Your first task is to make sure you have the tools needed to make this code
;; run at all.  You will first need to install node.  (https://nodejs.org).
;; After that, you need to install 'wabt' by typing the following:
;;
;;    shell % npm install wabt
;;
;; Finally, you will compile this file into WebAssembly using the following:
;;
;;    shell % ./node_modules/wabt/bin/wat2wasm code.wat
;;
;; Assuming that it worked, you should be able to run this code by typing:
;;
;;     shell % node main.js
;;     3628800
;;     0
;;     shell %

(module

 ;; Compute Factorial
 (func $fact (export "fact")
       (param $n i32)
       (result i32)
       (local $return i32)
       (local $result i32)
       i32.const 1
       local.set $result
       block $L1
          loop $L2
	     local.get $n
	     i32.const 0
	     i32.le_s
	     br_if $L1
	     local.get $result
	     local.get $n
	     i32.mul
	     local.set $result
	     local.get $n
	     i32.const 1
	     i32.sub
	     local.set $n
	  br $L2
          end
       end
       local.get $result
  )

  (func $sumn (export "sumn")
     (param $n i32)
     (result i32)
     (i32.const 0)
  )
 )

;; -----------------------------------------------------------------------------
;; Exercise 2.  Write a new Function
;;
;; Using the `fact` function as a guide, your next task is to implement the
;; `sumn` function above.  This function should sum the first n integers,
;; including the n.  Here is pseudocode in Python:
;;
;;    def sumn(n):
;;        result = 0
;;        while n > 0:
;;            result = result + n;
;;            n = n - 1;
;;        return result
;;
;; You should be able to do this by copying the `fact` code and making just a few
;; minor changes to it.



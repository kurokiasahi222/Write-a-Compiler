/* This JS program executes functions written in WebAssembly.
   To run this code, you first need to use the wat2wasm program that's
   part of the wabt package.  Follow these steps to build:

      shell % npm install wabt
      shell % ./node_modules/wabt/bin/wat2wasm code.wat

   To run this program type the following:

   shell % node main.js
   3628800
   55
   shell %
*/

const fs = require ('fs');
const bytes = fs.readFileSync (__dirname + '/code.wasm');

let importObject = { };

// Run the program.  
(async () => {
    const obj = await WebAssembly.instantiate (new Uint8Array(bytes), importObject);
    console.log(obj.instance.exports.fact(10));
    console.log(obj.instance.exports.sumn(10));    
})();

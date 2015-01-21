require! <[./index]>

index.init!
index.get \ladygaga .then -> console.log it
index.getAll <[obama putin]> .then -> console.log it

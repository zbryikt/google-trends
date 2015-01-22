require! <[./index]>

index.init!
index.get \ladygaga .then -> console.log it
index.getAll <[justin obama putin]> .then -> console.log it

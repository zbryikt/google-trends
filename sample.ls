require! <[./index]>

index.init!
index.get \ladygaga .then -> console.log it
index.getAll <[justin obama putin]> .then -> console.log it
index.format <[justin obama putin]> # space-aligned output to stdout
index.related <[obama]> .then (hash) -> console.log it # name - value pair for related keywords

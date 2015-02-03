google-trends
===================

So you want some scores from google-trends?


Usage
-------------------

You need first provide your cookie from Google.

 * Open browser, login to Google service such as Gmail or Google+
 * Open Dev console. switch to 'Network' tab.
 * Connect to www.google.com.
 * Right click the first item in 'Network' tab. choose 'Copy as cURL'.
 * Paste it in a file named 'curl', in your working directory.

Then

    trends = require("google-trends");
    trends.init();

    // Get current trend of ladygaga
    trends.get("ladygaga").then(function(hash) { ... });
    // hash = {"ladygaga": 5}

    // Get current trends of a set of keywords (normalized)
    trends.getAll(["justin","obama","putin"]).then(function(hash) { ...});
    // hash = {"justin": 20, "obama": 7, "putin": 1.25}

    // Formated getAll result in stdout
    trends.format(["justin","obama","putin"]);
    // space-aligned output to stdout

    // Get related keyword
    trends.related("obama").then(function(hash) { ... });
    // hash = {"barack obama": 100, "michelle obama": 40 ... }

    // Get related keywords
    trends.related(["obama","putin"]).then(function(hash) { ... });  
    // hash = {"obama": {"barack obama": 100, "michelle obama": 40 ... }, "putin": {...}}

    // Get related keywords recursively
    trends.recursiveRelated(["obama"]).then(function(hash) { ... });  
    // hash = {"barack obama": 100, "michelle obama": 40 ... }


Command Line Tools
---------------------

a script 'google-trend' is provided for easy access to google trends via command line, without scripting. usage:

    google-trend -- <action> [options...]
    available actions:
      related <keyword> [-d depth]
      get <keyword> [keywords...]

License
---------------------

CC-BY 4.0: https://creativecommons.org/licenses/by/4.0/

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
    trends.get("obama"); // will return {keyword: 'obama', value: 8}
    trends.getAll(["obama","putin"]); // return {obama: 8, putin:27}


License
---------------------

CC-BY 4.0: https://creativecommons.org/licenses/by/4.0/

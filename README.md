yago - Yet Another GetOpt
====

A pure Lua module for command line option parsing
----

***

I wrote this to handle command line options in a more table-centric manner which
aligns itself well with Lua's frequent use of tables.

yago can handle many styles of options, including GNU style long-options as well
as globbed short options. Such as:

* `<program> -a -b -c argToC arg1 arg2`
* `<program> --alpha -bc argToC arg1 arg2`
* `<program> -ab --gamma=argToC arg1 arg2`
* `<program> -a -b --gamma argToC arg1 arg2`
* `<program> -abcargToC arg1 arg2`

***

Usage
----
yago is easy to implement into your code, and returns the arg table with the
options removed and a table with your option flags.

***

### Example ###
`local yago = require 'yago'`

`shortOptString = 'a,     b,    c_' #Use _ to denote required option argument`

`longOptString  = 'alpha, beta, gamma'`

`arg, Opts = yago.getOpt(arg, shortOptString, longOptString)`

`if Opts.a then <...> end`

`if Opts.c_ == 'argToC' then <...> end`

***

Version & Changelog:
---
0.1.0 - Initial release

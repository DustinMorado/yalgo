yalgo - Yet Another Lua GetOpts
====

A pure Lua module for command line argument parsing
----

***

I wrote this to handle command line arguments in a more table-centric manner.

yago can handle many styles of options, including GNU style long-options as well
as globbed short options. Such as:

* `<program> -a -b -c arg_to_c arg1 arg2`
* `<program> --alpha -bc arg_to_c arg1 arg2`
* `<program> -ab --gamma=arg_to_c arg1 arg2`
* `<program> -a -b --gamma arg_to_c arg1 arg2`
* `<program> -abcarg_to_c arg1 arg2`

***

Usage
----
yalgo is easy to implement into your code, and returns a table indexed by option
names with the values found at the command line.

***

### Example ###
    local yalgo = require 'yalgo'
    parser = yalgo:new_parser('my program description')
    parser:add_argument({
      name = 'alpha',
      long_option = '--alpha',
      short_option = '-a',
      description = 'alpha option description' -- Used in parser:display_help()
    })
    my_parser:add_argument({
      name = 'beta',
      long_option = '--beta',
      short_option = '-b',
      description = 'beta option description'
    })
    my_parser:add_argument({
      name = 'gamma',
      long_option = '-gamma',
      short_option = '-c',
      has_argument = true, -- Option takes an argument
      is_required = true, -- Option is mandatory
      description = 'gamma option description',
      meta_value = 'ARG' -- Option argument place holder used in disp_help
    })
    my_parser:add_argument({
      name = 'arg1',
      is_positional = true, -- Specifies positional argument
      is_required = true,
      description = 'arg1 description',
      meta_value = 'ARG1'
    })
    my_parser:add_argument({
      name = 'arg2',
      is_positional = true,
      description = 'arg2 description',
      meta_value = 'ARG2'
    })
    options = my_parser:get_arguments()

    if options.alpha then
      -- code if --alpha or -a was given ...
    end

    if options.gamma == 'arg_to_c' then
      -- code if --gamma or -c was given with 'arg_to_c' argument
    end

***

Version & Changelog:
---
0.1.0 - Initial release

0.2.0 - Complete overhaul to more resemble Python's argparse module

0.3.0 - Another overhaul to tidy up code and fix some logic errors

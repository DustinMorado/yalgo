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
    my_parser = yalgo.Parser:new('my program description')
    my_parser:add_arg({
      name = 'alpha',
      l_opt = '--alpha',
      s_opt = '-a',
      descr = 'alpha option description' -- Option description used in disp_help
    })
    my_parser:add_arg({
      name = 'beta',
      l_opt = '--beta',
      s_opt = '-b',
      descr = 'beta option description'
    })
    my_parser:add_arg({
      name = 'gamma',
      l_opt = '-gamma',
      s_opt = '-c',
      has_arg = true, -- Option takes an argument
      is_reqd = true, -- Option is mandatory
      descr = 'gamma option description',
      meta_val = 'ARG' -- Option argument place holder used in disp_help
    })
    my_parser:add_arg({
      name = 'arg1',
      is_pos = true, -- Specifies positional argument
      is_reqd = true,
      descr = 'arg1 description',
      meta_val = 'ARG1'
    })
    my_parser:add_arg({
      name = 'arg2',
      is_pos = true,
      descr = 'arg2 description',
      meta_val = 'ARG2'
    })
    opts = my_parser:get_args()
    if opts.help then
      my_parser:disp_help()
      os.exit(0)
    end
    if opts.alpha then
      -- code if --alpha or -a was given ...
    end
    if opts.gamma == 'arg_to_c' then
      -- code if --gamma or -c was given with 'arg_to_c'
    end

***

Version & Changelog:
---
0.1.0 - Initial release

0.2.0 - Complete overhaul to more resemble Python's argparse module

--[[
Copyright (c) 2015 Dustin Reed Morado

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

--- Yet Another Lua Get Opts - Command line argument parser.
-- @module yalgo
-- @author Dustin Reed Morado
-- @license MIT
-- @release 0.2.0
local yalgo = {}

--- yalgo Parser class
-- @type Parser
yalgo.Parser = {}

local io, string, table = io, string, table
local dflt_arg = rawget(_G, 'arg')

--- Creates a new parser object:
--
-- returns a parser with the given description, and standard help options.
-- @usage my_parser = yalgo.Parser:new('A sample program description.')
-- @param descr A description for the CLI program you are parsing
-- @return A parser object
local function new (self, descr)
  if not descr then
    error('ERROR: yalgo.Parser:new: You must provide a program description.\n')
  end

  local parser = {}
  parser.descr = descr
  parser.args = {}
  table.insert(parser.args, {
    name = 'help',
    l_opt = '--help',
    s_opt = '-h',
    descr = 'Display this help and exit.'
  })
  parser.args.n = 1
  parser.args.n_pos = 0

  setmetatable(parser, self)
  self.__index = self
  -- We need to prevent this parser from calling new itself
  parser.new = function (self)
    error('ERROR: yalgo.Parser:new: Do not call new from a local parser.')
  end

  return parser
end

local function sort_args (arg_1, arg_2)
  -- Returns true if arg_1 should come before true arg_2

  -- Positional arguments always come after optional arguments
  -- If arg_1 is positional and arg_2 is not then arg_1 > arg_2
  if (arg_1.is_pos and (not arg_2.is_pos)) then
    return false

  -- If arg_1 is not positional and arg_2 is positional then arg_1 < arg_2
  elseif (arg_2.is_pos and (not arg_1.is_pos)) then
    return true

  -- If arg_1 and arg_2 are both postional then sort by position
  elseif (arg_1.is_pos and arg_2.is_pos) then
    return arg_1.pos < arg_2.pos

  -- If arg_1 and arg_2 are both optional then sort by option flags
  else
    -- If arg_1 and arg_2 both have long option flags sort alphabetically
    if (arg_1.l_opt and arg_2.l_opt) then
      return arg_1.l_opt < arg_2.l_opt

    -- If arg_1 has long option flag and arg_2 does not have a long option flag
    -- then sort by the first non-dash character alphabetically
    elseif (arg_1.l_opt and (not arg_2.l_opt)) then
      return (string.sub(arg_1.l_opt, 3, 3) < string.sub(arg_2.s_opt, 2, 2))

    -- If arg_1 does not have a long option flag and arg_2 does then sort by the
    -- first non-dash charcter alphabetically
    elseif ((not arg_1.l_opt) and arg_2.l_opt) then
      return (string.sub(arg_1.s_opt, 2, 2) <= string.sub(arg_2.l_opt, 3, 3))

    -- If arg_1 and arg_2 both do not have long option flags sort short flags
    -- alphabetically.
    else
      return arg_1.s_opt < arg_2.s_opt
    end
  end
end

--- Argument template for Parser.
-- This is a sample argument object for passing into add_arg.
--
-- l_opt and s_opt flags cannot be used for positional arguments, but at least
-- one must be given for an option argument.
--
-- Option arguments cannot be required and not take arguments.
--
-- Positional arguments cannot take arguments themselves.
--
-- Required arguments cannot specify a default value.
--
-- Description and meta_values are not mandatory unless you use the display_help
-- function (But of course you're providing adequate documentation right? ;))
local template_arg = {
  name = 'option', -- Argument name used as field in returned option table.
  l_opt = '--option', -- Specifies option long style flag
  s_opt = '-o', -- Specifies option short style flag
  is_pos = false, -- Indicaties whether argument is positional or an option
  has_arg = true, -- Indicates whether option takes an argument
  is_reqd = false, -- Indicates whether option is mandatory or not
  dflt_val = 10, -- Specifies a default value to be used for the option
  descr = 'lorem ipsum', -- Option description to be used for help
  meta_val = 'ARG', -- Specifies argument placeholder string used in help
}

--- Add an argument to a parser object
--
-- This function lets the parser know what arguments to look for at the command
-- line.
--
-- @usage my_parser:add_arg({name = 'option', l_opt = '--opt', ... })
-- @param _arg An argument table with the fields as described in template_arg
local function add_arg (self, _arg)
  -- Initial error handling for the most general errors
  -- Argument has to have a name
  if not _arg.name then
    error('ERROR: yalgo.Parser.add_arg: You must provide a name.')

  -- Argument name has to be a string
  elseif type(_arg.name) ~= 'string' then
    error('ERROR: yalgo.Parser.add_arg: _arg.name must be a string.')

  -- Parser cannot have two arguments with the same name
  elseif self.args[_arg.name] then
    error('ERROR: yalgo.Parser.add_arg: Option ' .. _arg.name ..
          ' already exists.')

  -- Optional argument long flag must be a string of the form '--option'
  elseif (_arg.l_opt and ((type(_arg.l_opt) ~= 'string') or
          (string.match(_arg.l_opt, '^%-%-%w[%w_-]+') ~= _arg.l_opt))) then
    error('ERROR: yalgo.Parser.add_arg: _arg.l_opt must be a valid string.')

  -- Optional argument short flag must be a string of the form '-x'
  elseif (_arg.s_opt and ((type(_arg.s_opt) ~= 'string') or
          (string.match(_arg.s_opt, '^%-%w') ~= _arg.s_opt))) then
    error('ERROR: yalgo.Parser.add_arg: _arg.s_opt must be a valid string.')

  -- Argument description must be a string
  elseif (_arg.descr and (type(_arg.descr) ~= 'string')) then
    error('ERROR: yalgo.Parser.add_arg: _arg.descr must be a string.')

  -- Argument meta value must be a string
  elseif (_arg.meta_val and (type(_arg.meta_val) ~= 'string')) then
    error('ERROR: yalgo.Parser.add_arg: _arg.meta_val must be string.')
  end

  -- Handle adding a positional argument first
  if _arg.is_pos then
    -- Positional arguments cannot take their own arguments
    if _arg.has_arg then
      error('ERROR: yalgo.Parser.add_arg: Positional arguments cannot take ' ..
            'their own arguments.')

    -- Positional arguments cannot specify long or short option flags
    elseif _arg.l_opt or _arg.s_opt then
      error('ERROR: yalgo.Parser.add_arg: Positional arguments cannot have ' ..
            'l_opt or s_opt values.')

    -- Positional arguments cannot both be required and have a default value
    elseif (_arg.is_reqd and _arg.dflt_val) then
      error('ERROR: yalgo.Parser.add_arg: Positional arguments cannot be ' ..
            'both required and have a default value.')

    else
      for i = 1, self.args.n do
        -- Positional arguments cannot be required if previous positional
        -- arguments are not required
        if (self.args[i].is_pos and (not self.args[i].is_reqd)) then
          error('ERROR: yalgo.Parser.add_arg: Positional argument cannot be ' ..
                'flagged as required if all prior positional arguments are ' ..
                'not required as well.')
        end
      end
      -- increment args table size and number of positional arguments
      self.args.n = self.args.n + 1
      self.args.n_pos = self.args.n_pos + 1
      _arg.pos = self.args.n_pos
    end

  -- Handle adding an optional argument
  else
    -- Optional arguments must have an option flag
    if (not _arg.l_opt or not _arg.s_opt) then
      error('ERROR: yalgo.Parser:add_arg: Optional arguments must specify ' ..
            'a long and or short option flag.')

    -- Optional arguments that are required must take an argument
    elseif (_arg.is_reqd and (not _arg.has_arg)) then
      error('ERROR: yalgo.Parser:add_arg: Required option arguments must ' ..
            'take an argument themselves.')

    else
      for i = 1, self.args.n do
        -- Optional arguments cannot have the same long option flag
        if self.args[i].l_opt == _arg.l_opt then
          error('ERROR: yalgo.Parser:add_arg: Option ' .. arg_name ..
                'already uses the long option ' .. _arg.l_opt .. '.')

        -- Optional arguments cannot have the same short option flag
        elseif self.args[i].s_opt == _arg.s_opt then
          error('ERROR: yalgo.Parser:add_arg: Option ' .. arg_name ..
                'already uses the short option ' .. _arg.s_opt .. '.')
        end
      end
      -- Increment args table size
      self.args.n = self.args.n + 1
    end
  end

  table.insert(self.args, {
    pos = _arg.pos,
    name = _arg.name,
    l_opt = _arg.l_opt,
    s_opt = _arg.s_opt,
    is_pos = _arg.is_pos,
    has_arg = _arg.has_arg,
    is_reqd = _arg.is_reqd,
    dflt_val = _arg.dflt_val,
    descr = _arg.descr,
    meta_val = _arg.meta_val
  })

  self.args[_arg.name] = self.args[self.args.n]
  table.sort(self.args, sort_args)
end

--- Display program help
--
-- Shows usage and detail optional and positional arguments
-- @usage my_parser:disp_help()
-- @param prog_name Program name, default is _G.arg[0]
local function disp_help (self, prog_name)
  prog_name = prog_name or _G.arg[0]

  -- Create and setup tables for Usage and arguments descriptions
  local args_usage, args_descr = {}, {}
  table.insert(args_usage, 'USAGE:')
  table.insert(args_usage, prog_name)
  table.insert(args_descr, 'OPTIONS:\n')

  -- We need to keep track when we switch from optional to positional
  local pos_switch = false
  for i = 1, self.args.n do
    -- Make sure that we have argument descriptions or meta values when approp.
    if (not self.args[i].descr or
        ((self.args[i].has_arg or self.args[i].is_pos) and
         (not self.args[i].meta_val))) then
      error('ERROR: yalgo.Parser.disp_help: ' .. arg_name .. ' does not ' ..
            'have a required description or meta_value.')
    end

    local arg_usage, arg_descr
    -- Handle positional arguments first
    if self.args[i].is_pos then
      -- If we run into our first positional argument we flip the pos_switch
      if not pos_switch then
        pos_switch = true
        table.insert(args_descr, 'ARGUMENTS:\n')
      end

      if self.args[i].is_reqd then
        arg_usage = self.args[i].meta_val
        arg_descr = '\t' .. self.args[i].meta_val .. '\n\t\t' ..
                    '[REQUIRED]: ' .. self.args[i].descr .. '\n'
      else
        arg_usage = '[' .. self.args[i].meta_val .. ']'
        arg_descr = '\t' .. self.args[i].meta_val .. '\n\t\t' ..
                    self.args[i].descr .. '\n'
      end

    -- Handle optional arguments
    else
      -- Optional arguments that are required must have arguments themselves
      if self.args[i].is_reqd then
        -- Both long and short option flags
        if (self.args[i].l_opt and self.args[i].s_opt) then
          -- --option|-x ARG
          arg_usage = self.args[i].l_opt .. '|' .. self.args[i].s_opt .. ' ' ..
                      self.args[i].meta_val
          -- --option, -x ARG
          --   [REQUIRED]: option description
          arg_descr = '\t' .. self.args[i].l_opt .. ', ' ..
                      self.args[i].s_opt .. ' ' .. self.args[i].meta_val ..
                      '\n\t\t' .. '[REQUIRED]: ' .. self.args[i].descr .. '\n'

        -- Only long option flag
        elseif (self.args[i].l_opt and (not self.args[i].s_opt)) then
          -- --option ARG
          arg_usage = self.args[i].l_opt .. ' ' .. self.args[i].meta_val
          -- --option ARG
          --   [REQUIRED]: option description
          arg_descr = '\t' .. self.args[i].l_opt .. ' ' ..
                      self.args[i].meta_val .. '\n\t\t' .. '[REQUIRED]: ' ..
                      self.args[i].descr .. '\n'

        -- Only short option flag
        elseif ((not self.args[i].l_opt) and self.args[i].s_opt) then
          -- -x ARG
          arg_usage = self.args[i].s_opt .. ' ' .. self.args[i].meta_val
          -- -x ARG
          --   [REQUIRED]: option description
          arg_descr = '\t' .. self.args[i].s_opt .. ' ' ..
                      self.args[i].meta_val .. '\n\t\t' .. '[REQUIRED]: ' ..
                      self.args[i].descr .. '\n'
        end

      -- Optional arguments that are not required may or may not have arguments
      else
        -- Handle Optional arguments with arguments
        if self.args[i].has_arg then
          -- Both long and short options
          if (self.args[i].l_opt and self.args[i].s_opt) then
            -- [--option|-x ARG]
            arg_usage = '[' .. self.args[i].l_opt .. '|' ..
                        self.args[i].s_opt .. ' ' .. self.args[i].meta_val ..
                        ']'
            -- --option, -x ARG
            --   option description
            arg_descr = '\t' .. self.args[i].l_opt .. ', ' ..
                        self.args[i].s_opt .. ' ' .. self.args[i].meta_val ..
                        '\n\t\t' .. self.args[i].descr .. '\n'

          -- Only long option flag
          elseif (self.args[i].l_opt and (not self.args[i].s_opt)) then
            -- [--option ARG]
            arg_usage = '[' .. self.args[i].l_opt .. ' ' ..
                        self.args[i].meta_val .. ']'
            -- --option ARG
            --   option description
            arg_descr = '\t' .. self.args[i].l_opt .. ' ' ..
                        self.args[i].meta_val .. '\n\t\t' ..
                        self.args[i].descr .. '\n'

          -- Only short option flag
          elseif ((not self.args[i].l_opt) and self.args[i].s_opt) then
            -- [-x ARG]
            arg_usage = '[' .. self.args[i].s_opt .. ' ' ..
                        self.args[i].meta_val .. ']'
            -- -x ARG
            --   option description
            arg_descr = '\t' .. self.args[i].s_opt .. ' ' ..
                        self.args[i].meta_val .. '\n\t\t' ..
                        self.args[i].descr .. '\n'
          end

        -- Handle optional arguments without arguments
        else
          -- Both long and short options
          if (self.args[i].l_opt and self.args[i].s_opt) then
            -- [--option|-x]
            arg_usage = '[' .. self.args[i].l_opt .. '|' ..
                        self.args[i].s_opt .. ']'
            -- --option, -x
            --   option description
            arg_descr = '\t' .. self.args[i].l_opt .. ', ' ..
                        self.args[i].s_opt .. '\n\t\t' .. self.args[i].descr ..
                        '\n'

          -- Only long option flag
          elseif (self.args[i].l_opt and (not self.args[i].s_opt)) then
            -- [--option]
            arg_usage = '[' .. self.args[i].l_opt .. ']'
            -- --option
            --   option description
            arg_descr = '\t' .. self.args[i].l_opt .. '\n\t\t' ..
                        self.args[i].descr .. '\n'

          -- Only short option flag
          elseif ((not self.args[i].l_opt) and self.args[i].s_opt) then
            -- [-x]
            arg_usage = '[' .. self.args[i].s_opt .. ']'
            -- -x
            --   option description
            arg_descr = '\t' .. self.args[i].s_opt .. '\n\t\t' ..
                        self.args[i].descr .. '\n'
          end
        end
      end
    end

    table.insert(args_usage, arg_usage)
    table.insert(args_descr, arg_descr)
  end

  io.write(self.descr .. '\n')
  io.write(table.concat(args_usage, ' ') .. '\n')
  io.write(table.concat(args_descr, '') .. '\n')
end

local function is_opt (_arg)
  if not _arg then
    return false
  elseif _arg == '-' then
    return false
  elseif _arg == '--' then
    return false
  elseif string.match(_arg, '^%-%-?') then
    return true
  else
    return false
  end
end

local function is_l_opt (_arg)
  if string.sub(_arg, 1, 2) == '--' then
    return true
  else
    return false
  end
end

local function find_opt_name (self, _arg)
  local opt_type, opt_name, opt_flag
  if is_l_opt(_arg) then
    opt_type = 'l_opt'
    opt_flag = string.match(_arg, '([%w_-]+)=?')
  else
    opt_type = 's_opt'
    opt_flag = string.sub(_arg, 1, 2)
  end

  for i = 1, self.args.n do
    if opt_flag == self.args[i][opt_type] then
      opt_name = self.args[i].name
      break
    end
  end

  if not opt_name then
    error('ERROR: yalgo.Parser:get_args: ' .. _arg .. ' is not a valid ' ..
          'argument.')
  end

  return opt_name
end

local function find_opt_arg_and_shift (self, args, _arg, opt_name)
  local opt_arg
  local has_eq = string.find(_arg, '=')
  local eq_idx = has_eq
  -- Handle long options
  if is_l_opt(_arg) then
    if has_eq then -- --option=ARG
      if not self.args[opt_name].has_arg then
        error('ERROR: yalgo.Parser:get_args: ' .. self.args[opt_name].l_opt ..
              ' does not take arguments.')
      end

      opt_arg = string.sub(_arg, (eq_idx + 1), -1)
      table.remove(args, 1)

    elseif self.args[opt_name].has_arg then -- --option ARG
      if not args[2] then
        error('ERROR: yalgo.Parser.get_args: ' .. self.args[opt_name].l_opt ..
              ' requires an argument.')
      else
        opt_arg = args[2]
        table.remove(args, 1)
        table.remove(args, 1)
      end

    else -- --option
      table.remove(args, 1)
    end

  -- Handle short options
  else
    local has_glob = string.len(_arg) > 2
    if eq_idx == 3 then -- -x=ARG
      if not self.args[opt_name].has_arg then
        error('ERROR: yalgo.Parser:get_args: ' .. self.args[opt_name].s_opt ..
              ' does not take arguments.')
      end

      opt_arg = string.sub(_arg, (eq_idx + 1), -1)
      table.remove(args, 1)

    elseif (has_glob and self.args[opt_name].has_arg) then -- -xARG
      opt_arg = string.sub(_arg, 3, -1)
      table.remove(args, 1)

    elseif self.args[opt_name].has_arg then -- -x ARG
      if not args[2] then
        error('ERROR: yalgo.Parser.get_args: ' .. self.args[opt_name].s_opt ..
              ' requires an argument.')
      else
        opt_arg = args[2]
        table.remove(args, 1)
        table.remove(args, 1)
      end

    else -- -x
      if has_glob then -- -xabc
        args[1] = '-' .. string.sub(_arg, 3, -1)
      else
        table.remove(args, 1)
      end
    end
  end

  return opt_arg
end

--- Get arguments
--
-- takes an arg table and updates the parser arg table values returning a table
-- indexed by argument name storing the found and default values.
-- @usage found_args = my_parser:get_args()
-- @param args Sequence table of arguments, default is _G.arg
-- @return A table indexed by parser argument name with found and default values
local function get_args (self, args)
  args = args or dflt_arg
  local _args = {}
  -- Setup the return table with default values from the parser
  for i = 1, self.args.n do
    _args[self.args[i].name] = self.args[i].dflt_val
  end

  local _arg = args[1]
  -- Handle optional arguments
  while is_opt(_arg) do
    local opt_name = find_opt_name(self, _arg)
    _args[opt_name] = _args[opt_name] or true
    local opt_arg = find_opt_arg_and_shift(self, args, _arg, opt_name)
    _args[opt_name] = opt_arg or _args[opt_name]
    _arg = args[1]
  end

  -- Handle positional arguments
  for i = 1, self.args.n_pos do
    pos_idx = self.args.n - self.args.n_pos + i
    pos_name = self.args[pos_idx].name
    _args[pos_name] = args[1] or _args[pos_name]
    table.remove(args, 1)
  end

  -- Check for all required arguments
  for i = 1, self.args.n do
    if (self.args[i].is_reqd and (not _args[self.args[i].name])) then
      error('ERROR: yalgo.Parser:get_args: ' .. self.args[i].name .. ' is ' ..
            'required and was not given.')
    end
  end

  return _args
end

--- @export
yalgo.Parser = {
  new = new,
  add_arg = add_arg,
  get_args = get_args,
  disp_help = disp_help,
  template_arg = template_arg
}

return yalgo

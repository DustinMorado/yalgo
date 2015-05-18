describe('Create local parser', function ()
  local yalgo
  local parser

  setup(function ()
    yalgo = require 'yalgo'
  end)

  teardown(function ()
    yalgo = nil
  end)

  before_each(function ()
    parser = yalgo.Parser:new('My test parser')
  end)

  after_each(function ()
    parser = nil
  end)

  it('Parser should be a table', function ()
    assert.are.equal(type(parser), 'table')
  end)

  it('Parser should have a description', function ()
    assert.are.equal(type(parser.descr), 'string')
    assert.are.equal(parser.descr, 'My test parser')
  end)

  it('Parser should have an arguments table', function ()
    assert.are.equal(type(parser.args), 'table')
    assert.are.equal(parser.args[1].name, 'help')
    assert.are.equal(parser.args[1].l_opt, '--help')
    assert.are.equal(parser.args[1].s_opt, '-h')
    assert.are.equal(parser.args[1].descr, 'Display this help and exit.')
  end)

  it('Parser should have a length field', function ()
    assert.are.equal(parser.args.n, 1)
  end)

  it('Parser should have a positional argument length field', function ()
    assert.are.equal(parser.args.n_pos, 0)
  end)

  it('Parser should throw error if constructed without description', function ()
    assert.has_error(function() yalgo.Parser:new() end)
  end)

  it('Parser should have yalgo.parser as metatable', function ()
    assert.is.truthy(getmetatable(parser))
    assert.are.equal(getmetatable(parser), yalgo.Parser)
  end)

  it('Parser should have all the necessary functions', function ()
    assert.are.equal(type(parser.add_arg), 'function')
    assert.are.equal(type(parser.disp_help), 'function')
    assert.are.equal(type(parser.get_args), 'function')
  end)

  it('Parser should not have access to new itself', function ()
    assert.has_error(function () parser:new() end)
  end)
end)

describe('Create local parser', function ()
  local yalgo

  setup(function ()
    yalgo = require 'yalgo'
  end)

  teardown(function ()
    yalgo = nil
  end)

  before_each(function ()
    parser = yalgo:new_parser()
  end)

  after_each(function ()
    parser = nil
  end)

  it('Parser should be a table', function ()
    assert.are.equal(type(parser), 'table')
  end)

  it('Parser should have a description', function ()
    assert.are.equal(type(parser.description), 'string')
    assert.are.equal(parser.description, '')
  end)

  it('Parser should have an arguments table', function ()
    assert.are.equal(type(parser.arguments), 'table')
    assert.are.equal(parser.arguments[1].name, 'help')
    assert.are.equal(parser.arguments[1].long_option, '--help')
    assert.are.equal(parser.arguments[1].short_option, '-h')
    assert.are.equal(parser.arguments[1].description,
                     'Display this help and exit.')
  end)

  it('Parser should have a length field', function ()
    assert.are.equal(#parser.arguments, 1)
  end)

  it('Parser should have a positional index tracker', function ()
    assert.are.equal(parser.positional_index, 2)
  end)

  it('Parser should have yalgo.parser as metatable', function ()
    assert.is.truthy(getmetatable(parser))
    assert.are.equal(getmetatable(parser), yalgo)
  end)

  it('Parser should have all the necessary functions', function ()
    assert.are.equal(type(parser.add_argument), 'function')
    assert.are.equal(type(parser.display_help), 'function')
    assert.are.equal(type(parser.get_arguments), 'function')
  end)

  it('Parser should not have access to new itself', function ()
    assert.has_error(function () parser:new_parser() end)
  end)
end)

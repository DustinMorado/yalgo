describe('Test getting CLI arguments', function()
  local yalgo
  local parser
  local opt1, opt2, opt3, opt4

  setup(function()
    yalgo = require 'yalgo'
  end)

  teardown(function()
    yalgo = nil
  end)

  before_each(function()
    parser = yalgo:new_parser()
    alpha = {
      name = 'alpha',
      long_option = '--alpha',
      short_option = '-a',
      description = 'alpha option description.'
    }

    beta = {
      name = 'beta',
      long_option = '--beta',
      short_option = '-b',
      default_value = 10,
      has_argument = true,
      description = 'beta option description.',
      meta_value = 'NUM'
    }

    gamma = {
      name = 'gamma',
      long_option = '--gamma',
      short_option = '-c',
      is_required = true,
      has_argument = true,
      description = 'gamma option description.',
      meta_value = 'FILE'
    }

    delta = {
      name = 'delta',
      long_option = '--delta',
      description = 'delta option description.'
    }

    epsilon = {
      name = 'epsilon',
      short_option = '-e',
      description = 'epsilon option description.'
    }

    arg1 = {
      name = 'arg1',
      is_positional = true,
      is_required = true,
      description = 'arg1 pos argument description.',
      meta_value = 'FILE'
    }

    arg2 = {
      name = 'arg2',
      is_positional = true,
      default_value = 'output.txt',
      description = 'arg2 pos argument description.',
      meta_value = 'FILE'
    }
    parser:add_argument(alpha)
    parser:add_argument(beta)
    parser:add_argument(gamma)
    parser:add_argument(delta)
    parser:add_argument(epsilon)
    parser:add_argument(arg1)
    parser:add_argument(arg2)
  end)

  after_each(function()
    parser, alpha, beta, gamma, delta, epsilon, arg1, arg2 = nil
  end)

  it('Should handle just the required aruments.', function ()
    arguments = { [0] = 'myprog', '-c', '5', 'input.txt' }
    options = parser:get_arguments(arguments)
    assert.are.equal(options.gamma, '5')
    assert.are.equal(options.arg1, 'input.txt')
  end)

  it('Should handle basic input.', function ()
    arguments = { [0] = 'myprog', '-a', '-b', '25', '-c', '5', '--delta', '-e',
                  'arg1', 'arg2' }
    options = parser:get_arguments(arguments)
    assert.is.True(options.alpha)
    assert.are.equal(options.beta, '25')
    assert.are.equal(options.gamma, '5')
    assert.is.True(options.delta)
    assert.is.True(options.epsilon)
    assert.are.equal(options.arg1, 'arg1')
    assert.are.equal(options.arg2, 'arg2')
  end)

  it('Should handle GNU-style long options.', function ()
    arguments = { [0] = 'myprog', '-aeb25', '--gamma', '5', '--delta', 'arg1',
                  'arg2' }
    options = parser:get_arguments(arguments)
    assert.is.True(options.alpha)
    assert.are.equal(options.beta, '25')
    assert.are.equal(options.gamma, '5')
    assert.is.True(options.delta)
    assert.is.True(options.epsilon)
    assert.are.equal(options.arg1, 'arg1')
    assert.are.equal(options.arg2, 'arg2')
  end)

  it('Should handle GNU-style long option with equals signs.', function ()
    arguments = { [0] = 'myprog', '-ab=25', '--gamma=5', 'arg1', 'arg2' }
    options = parser:get_arguments(arguments)
    assert.is.True(options.alpha)
    assert.are.equal(options.beta, '25')
    assert.are.equal(options.gamma, '5')
    assert.are.equal(options.arg1, 'arg1')
    assert.are.equal(options.arg2, 'arg2')
  end)

  it('Should leave unspecified arguments in place in arg.', function ()
    arguments = { [0] = 'myprog', '--alpha', '-b=25', '--gamma', '5', 'arg1',
                  'arg2', 'arg3', 'arg4' }
    options = parser:get_arguments(arguments)
    assert.is.True(options.alpha)
    assert.are.equal(options.beta, '25')
    assert.are.equal(options.gamma, '5')
    assert.are.equal(options.arg1, 'arg1')
    assert.are.equal(options.arg2, 'arg2')
    assert.are.equal(arguments[1], 'arg3')
    assert.are.equal(arguments[2], 'arg4')
  end)
end)

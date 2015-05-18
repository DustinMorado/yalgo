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
    parser = yalgo.Parser:new('My test parser')
    alpha = {
      name = 'alpha',
      l_opt = '--alpha',
      s_opt = '-a',
      descr = 'alpha option description.'
    }

    beta = {
      name = 'beta',
      l_opt = '--beta',
      s_opt = '-b',
      dflt_val = 10,
      has_arg = true,
      descr = 'beta option description.',
      meta_val = 'NUM'
    }

    gamma = {
      name = 'gamma',
      l_opt = '--gamma',
      s_opt = '-c',
      is_reqd = true,
      has_arg = true,
      descr = 'gamma option description.',
      meta_val = 'FILE'
    }

    arg1 = {
      name = 'arg1',
      is_pos = true,
      is_reqd = true,
      descr = 'arg1 pos argument description.',
      meta_val = 'FILE'
    }

    arg2 = {
      name = 'arg2',
      is_pos = true,
      dflt_val = 'output.txt',
      descr = 'arg2 pos argument description.',
      meta_val = 'FILE'
    }
    parser:add_arg(alpha)
    parser:add_arg(beta)
    parser:add_arg(gamma)
    parser:add_arg(arg1)
    parser:add_arg(arg2)
  end)

  after_each(function()
    parser, alpha, beta, gamma, arg1, arg2 = nil
  end)

  it('Should handle just the required aruments.', function ()
    args = { [0] = 'myprog', '-c', '5', 'input.txt' }
    opts = parser:get_args(args)
    assert.are.equal(opts['gamma'], '5')
    assert.are.equal(opts['arg1'], 'input.txt')
  end)

  it('Should handle basic input.', function ()
    args = { [0] = 'myprog', '-a', '-b', '25', '-c', '5', 'arg1', 'arg2' }
    opts = parser:get_args(args)
    assert.is.True(opts['alpha'])
    assert.are.equal(opts['beta'], '25')
    assert.are.equal(opts['gamma'], '5')
    assert.are.equal(opts['arg1'], 'arg1')
    assert.are.equal(opts['arg2'], 'arg2')
  end)

  it('Should handle GNU-style long options.', function ()
    args = { [0] = 'myprog', '-ab25', '--gamma', '5', 'arg1', 'arg2' }
    opts = parser:get_args(args)
    assert.is.True(opts['alpha'])
    assert.are.equal(opts['beta'], '25')
    assert.are.equal(opts['gamma'], '5')
    assert.are.equal(opts['arg1'], 'arg1')
    assert.are.equal(opts['arg2'], 'arg2')
  end)

  it('Should handle GNU-style long option with equals signs.', function ()
    args = { [0] = 'myprog', '-ab=25', '--gamma=5', 'arg1', 'arg2' }
    opts = parser:get_args(args)
    assert.is.True(opts['alpha'])
    assert.are.equal(opts['beta'], '25')
    assert.are.equal(opts['gamma'], '5')
    assert.are.equal(opts['arg1'], 'arg1')
    assert.are.equal(opts['arg2'], 'arg2')
  end)

  it('Should leave unspecified arguments in place in arg.', function ()
    args = { [0] = 'myprog', '--alpha', '-b=25', '--gamma', '5', 'arg1', 'arg2',
             'arg3', 'arg4' }
    opts = parser:get_args(args)
    assert.is.True(opts['alpha'])
    assert.are.equal(opts['beta'], '25')
    assert.are.equal(opts['gamma'], '5')
    assert.are.equal(opts['arg1'], 'arg1')
    assert.are.equal(opts['arg2'], 'arg2')
    assert.are.equal(args[1], 'arg3')
    assert.are.equal(args[2], 'arg4')
  end)
end)

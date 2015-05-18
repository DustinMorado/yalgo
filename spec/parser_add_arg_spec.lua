describe('Test adding options to parser', function ()
  local yalgo
  local parser

  setup(function ()
    yalgo = require('yalgo')
  end)

  teardown(function ()
    yalgo = nil
  end)

  before_each(function ()
    parser = yalgo.Parser:new('A test parser')
  end)

  after_each(function ()
    parser = nil
  end)

  describe('Test general add_arg errors', function ()
    it('Should not be able to add argument without name', function ()
      assert.has.errors(function ()
        parser:add_arg({
          l_opt = '--alpha',
          s_opt = '-a',
          descr = 'alpha option description.'
        })
      end)
    end)

    it('Should not be able to add argument that\'s not a string', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 5,
          l_opt = '--five',
          s_opt = '-5',
          descr = 'five option description.'
        })
      end)
    end)

    it('Should not be able to add arguments with same name', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'alpha',
          l_opt = '--alpha',
          s_opt = '-a',
          descr = 'alpha option description.'
        })
        parser:add_arg({
          name = 'alpha',
          l_opt = '--alpha2',
          s_opt = '-A',
          descr = 'alpha option description.'
        })
      end)
    end)

    it('Should not be able to add argument with invalid long option flag',
       function ()
         assert.has.errors(function ()
           parser:add_arg({
             name = 'alpha',
             l_opt = 5,
             s_opt = '-a',
             descr = 'alpha option description.'
           })
         end)

         assert.has.errors(function ()
           parser:add_arg({
             name = 'alpha',
             l_opt = 'alpha',
             s_opt = '-a',
             descr = 'alpha option description.'
           })
         end)

         assert.has.errors(function ()
           parser:add_arg({
             name = 'alpha',
             l_opt = '-a',
             s_opt = '-a',
             descr = 'alpha option description.'
           })
         end)
    end)

    it('Should not be able to add argument with invalid short option flag',
       function ()
         assert.has.errors(function ()
           parser:add_arg({
             name = 'alpha',
             l_opt = '--alpha',
             s_opt = 5,
             descr = 'alpha option description.'
           })
         end)

         assert.has.errors(function ()
           parser:add_arg({
             name = 'alpha',
             l_opt = '--alpha',
             s_opt = 'a',
             descr = 'alpha option description.'
           })
         end)

         assert.has.errors(function ()
           parser:add_arg({
             name = 'alpha',
             l_opt = '--alpha',
             s_opt = '--a',
             descr = 'alpha option description.'
           })
         end)
    end)

    it('Should not be able to add description that\'s not a string', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'alpha',
          l_opt = '--alpha',
          s_opt = '-a',
          descr = 5
        })
      end)
    end)

    it('Should not be able to add meta value that\'s not a string', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'gamma',
          l_opt = '--gamma',
          s_opt = '-c',
          has_arg = true,
          descr = 'gamma option description.',
          meta_val = 5
        })
      end)
    end)
  end)

  describe('Test adding positional arguments', function ()
    it('Should not be able to take it\'s own arguments', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'arg1',
          is_pos = true,
          has_arg = true,
          descr = 'arg1 positional argument description.'
        })
      end)
    end)

    it('Should not be able to take long or short option flags', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'arg1',
          l_opt = '--arg1',
          is_pos = true,
          descr = 'arg1 positional argument description.'
        })
      end)

      assert.has.errors(function ()
        parser:add_arg({
          name = 'arg1',
          s_opt = '-a',
          is_pos = true,
          descr = 'arg1 positional argument description.'
        })
      end)
    end)

    it('Should not be able to be required and have a default value', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'arg1',
          is_pos = true,
          is_reqd = true,
          dflt_val = 'arg1',
          descr = 'arg1 positional argument description.'
        })
      end)
    end)

    it('Should not be able to be required if all prev. pos. arg. weren\'t',
       function ()
         parser:add_arg({
           name = 'arg1',
           is_pos = true,
           descr = 'arg1 positional argument description.'
         })

         assert.has.errors(function ()
           parser:add_arg({
             name = 'arg2',
             is_pos = true,
             is_reqd = true,
             descr = 'arg2 positional argument description.'
           })
         end)
    end)

    it('Should be able to add valid positional arguments', function ()
      parser:add_arg({
        name = 'arg1',
        is_pos = true,
        is_reqd = true,
        descr = 'arg1 positonal argument description.',
        meta_val = 'arg1'
      })

      parser:add_arg({
        name = 'arg2',
        is_pos = true,
        descr = 'arg2 positional argument description.',
        meta_val = 'arg2'
      })

      assert.are.equal(parser.args.n, 3)
      assert.are.equal(parser.args.n_pos, 2)
      assert.are.equal(parser.args[2].name, 'arg1')
      assert.are.equal(parser.args[3].name, 'arg2')
      assert.is_true(parser.args[2].is_pos)
      assert.is_true(parser.args[3].is_pos)
    end)
  end)

  describe('Test adding optional arguments', function ()
    it('Should not be able to make options with no flags', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'alpha',
          descr = 'alpha option description.'
        })
      end)
    end)

    it('Should not be to be required and not take an argument', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'gamma',
          l_opt = '--gamma',
          s_opt = '-c',
          is_reqd = true,
          descr = 'gamma option description.'
        })
      end)
    end)

    it('Should not be able to specify the same long option flag.', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'alpha',
          l_opt = '--alpha',
          s_opt = '-a',
          descr = 'alpha option description.'
        })

        parser:add_arg({
          name = 'Alpha',
          l_opt = '--alpha',
          s_opt = '-A',
          descr = 'Alpha option description.'
        })
      end)
    end)

    it('Should not be able to specify the same short option flag.', function ()
      assert.has.errors(function ()
        parser:add_arg({
          name = 'alpha',
          l_opt = '--alpha',
          s_opt = '-a',
          descr = 'alpha option description.'
        })

        parser:add_arg({
          name = 'Alpha',
          l_opt = '--Alpha',
          s_opt = '-a',
          descr = 'Alpha option description.'
        })
      end)
    end)

    it('Should be able to add valid option flags.', function ()
      parser:add_arg({
        name = 'alpha',
        l_opt = '--alpha',
        s_opt = '-a',
        descr = 'alpha option description.'
      })

      parser:add_arg({
        name = 'beta',
        l_opt = '--beta',
        s_opt = '-b',
        descr = 'beta option description.'
      })

      parser:add_arg({
        name = 'gamma',
        l_opt = '--gamma',
        s_opt = '-c',
        is_reqd = true,
        has_arg = true,
        descr = 'gamma option description.',
        meta_val = 'ARG_TO_C'
      })

      assert.are.equal(parser.args.n, 4)
      assert.are.equal(parser.args.n_pos, 0)
      assert.are.equal(parser.args[1].name, 'alpha')
      assert.are.equal(parser.args[2].name, 'beta')
      assert.are.equal(parser.args[3].name, 'gamma')
      assert.are.equal(parser.args[1].l_opt, '--alpha')
      assert.are.equal(parser.args[2].l_opt, '--beta')
      assert.are.equal(parser.args[3].l_opt, '--gamma')
      assert.are.equal(parser.args[1].s_opt, '-a')
      assert.are.equal(parser.args[2].s_opt, '-b')
      assert.are.equal(parser.args[3].s_opt, '-c')
      assert.is_true(parser.args[3].is_reqd)
      assert.is_true(parser.args[3].has_arg)
    end)
  end)
end)

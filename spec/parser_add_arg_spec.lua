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
    parser = yalgo:new_parser()
  end)

  after_each(function ()
    parser = nil
  end)

  describe('Test general add_argument errors', function ()
    it('Should not be able to add argument without name', function ()
      assert.has.errors(function ()
        parser:add_argument({
          long_option = '--alpha',
          short_option = '-a',
          description = 'alpha option description.'
        })
      end)
    end)

    it('Should not be able to add argument that\'s not a string', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 5,
          long_option = '--five',
          short_option = '-5',
          description = 'five option description.'
        })
      end)
    end)

    it('Should not be able to add arguments with same name', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'alpha',
          long_option = '--alpha',
          short_option = '-a',
          description = 'alpha option description.'
        })
        parser:add_argument({
          name = 'alpha',
          long_option = '--alpha2',
          short_option = '-A',
          description = 'alpha option description.'
        })
      end)
    end)

    it('Should not be able to add argument with invalid long option flag',
       function ()
         assert.has.errors(function ()
           parser:add_argument({
             name = 'alpha',
             long_option = 5,
             short_option = '-a',
             description = 'alpha option description.'
           })
         end)

         assert.has.errors(function ()
           parser:add_argument({
             name = 'alpha',
             long_option = 'alpha',
             short_option = '-a',
             description = 'alpha option description.'
           })
         end)

         assert.has.errors(function ()
           parser:add_argument({
             name = 'alpha',
             long_option = '-a',
             short_option = '-a',
             description = 'alpha option description.'
           })
         end)
    end)

    it('Should not be able to add argument with invalid short option flag',
       function ()
         assert.has.errors(function ()
           parser:add_argument({
             name = 'alpha',
             long_option = '--alpha',
             short_option = 5,
             description = 'alpha option description.'
           })
         end)

         assert.has.errors(function ()
           parser:add_argument({
             name = 'alpha',
             long_option = '--alpha',
             short_option = 'a',
             description = 'alpha option description.'
           })
         end)

         assert.has.errors(function ()
           parser:add_argument({
             name = 'alpha',
             long_option = '--alpha',
             short_option = '--a',
             description = 'alpha option description.'
           })
         end)
    end)

    it('Should not be able to add description that\'s not a string', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'alpha',
          long_option = '--alpha',
          short_option = '-a',
          description = 5
        })
      end)
    end)

    it('Should not be able to add meta value that\'s not a string', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'gamma',
          long_option = '--gamma',
          short_option = '-c',
          has_argument = true,
          description = 'gamma option description.',
          meta_value = 5
        })
      end)
    end)
  end)

  describe('Test adding positional arguments', function ()
    it('Should not be able to take it\'s own arguments', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'arg1',
          is_positional = true,
          has_argument = true,
          description = 'arg1 positional argument description.'
        })
      end)
    end)

    it('Should not be able to take long or short option flags', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'arg1',
          long_option = '--arg1',
          is_positional = true,
          description = 'arg1 positional argument description.'
        })
      end)

      assert.has.errors(function ()
        parser:add_argument({
          name = 'arg1',
          short_option = '-a',
          is_positional = true,
          description = 'arg1 positional argument description.'
        })
      end)
    end)

    it('Should not be able to be required and have a default value', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'arg1',
          is_positional = true,
          is_required = true,
          default_value = 'arg1',
          description = 'arg1 positional argument description.'
        })
      end)
    end)

    it('Should not be able to be required if all prev. pos. arg. weren\'t',
       function ()
         parser:add_argument({
           name = 'arg1',
           is_positional = true,
           description = 'arg1 positional argument description.'
         })

         assert.has.errors(function ()
           parser:add_argument({
             name = 'arg2',
             is_positional = true,
             is_required = true,
             description = 'arg2 positional argument description.'
           })
         end)
    end)

    it('Should be able to add valid positional arguments', function ()
      parser:add_argument({
        name = 'arg1',
        is_positional = true,
        is_required = true,
        description = 'arg1 positonal argument description.',
        meta_value = 'arg1'
      })

      parser:add_argument({
        name = 'arg2',
        is_positional = true,
        description = 'arg2 positional argument description.',
        meta_value = 'arg2'
      })

      parser:add_argument({
        name = 'arg3',
        is_positional = true,
        description = 'arg3 positional argument description.',
        meta_value = 'arg3'
      })

      assert.are.equal(#parser.arguments, 4)
      assert.are.equal(parser.positional_index, 2)
      assert.are.equal(parser.arguments[2].name, 'arg1')
      assert.are.equal(parser.arguments[3].name, 'arg2')
      assert.are.equal(parser.arguments[4].name, 'arg3')
      assert.is_true(parser.arguments[2].is_positional)
      assert.is_true(parser.arguments[3].is_positional)
      assert.is_true(parser.arguments[4].is_positional)
    end)
  end)

  describe('Test adding optional arguments', function ()
    it('Should not be able to make options with no flags', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'alpha',
          description = 'alpha option description.'
        })
      end)
    end)

    it('Should not be to be required and not take an argument', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'gamma',
          long_option = '--gamma',
          short_option = '-c',
          is_required = true,
          description = 'gamma option description.'
        })
      end)
    end)

    it('Should not be able to specify the same long option flag.', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'alpha',
          long_option = '--alpha',
          short_option = '-a',
          description = 'alpha option description.'
        })

        parser:add_argument({
          name = 'Alpha',
          long_option = '--alpha',
          short_option = '-A',
          description = 'Alpha option description.'
        })
      end)
    end)

    it('Should not be able to specify the same short option flag.', function ()
      assert.has.errors(function ()
        parser:add_argument({
          name = 'alpha',
          long_option = '--alpha',
          short_option = '-a',
          description = 'alpha option description.'
        })

        parser:add_argument({
          name = 'Alpha',
          long_option = '--Alpha',
          short_option = '-a',
          description = 'Alpha option description.'
        })
      end)
    end)

    it('Should be able to add valid option flags.', function ()
      parser:add_argument({
        name = 'alpha',
        long_option = '--alpha',
        short_option = '-a',
        description = 'alpha option description.'
      })

      parser:add_argument({
        name = 'beta',
        long_option = '--beta',
        short_option = '-b',
        description = 'beta option description.'
      })

      parser:add_argument({
        name = 'gamma',
        long_option = '--gamma',
        short_option = '-c',
        is_required = true,
        has_argument = true,
        description = 'gamma option description.',
        meta_value = 'ARG_TO_C'
      })

      assert.are.equal(#parser.arguments, 4)
      assert.are.equal(parser.positional_index, 5)
      assert.are.equal(parser.arguments[1].name, 'alpha')
      assert.are.equal(parser.arguments[2].name, 'beta')
      assert.are.equal(parser.arguments[3].name, 'gamma')
      assert.are.equal(parser.arguments[1].long_option, '--alpha')
      assert.are.equal(parser.arguments[2].long_option, '--beta')
      assert.are.equal(parser.arguments[3].long_option, '--gamma')
      assert.are.equal(parser.arguments[1].short_option, '-a')
      assert.are.equal(parser.arguments[2].short_option, '-b')
      assert.are.equal(parser.arguments[3].short_option, '-c')
      assert.is_true(parser.arguments[3].is_required)
      assert.is_true(parser.arguments[3].has_argument)
    end)
  end)
end)

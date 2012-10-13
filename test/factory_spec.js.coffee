#= require ./../factories

describe 'Factory', ->

  beforeEach ->
    Factory.define 'user', (args...) ->
      args: args

  afterEach ->
    Factory.resetFactories()

  describe '::define', ->

    it 'registers a factory', ->
      result = Factory.create 'user'
      result.args.should.deep.equal []

    it 'raises an error on existing factory', ->
      expect(-> Factory.define('user', ->)).to.throw 'Factory user is already defined'

    it 'raises an error on naming conflict with traits', ->
      expect(-> Factory.define('admin-user', ->)).to.throw 'Factory name \'admin-user\' can\'t use - in name. It clashes with the traits construct'

  describe '::create', ->

    it 'delivers options to the callback', ->
      result = Factory.create 'user'
        hello: 'world'
        other: 'value'
      result.args[0].should.deep.equal { hello: 'world', other: 'value' }

    it 'accepts multiple arguments', ->
      result = Factory.create 'user', 1, 2, 3
      result.args.should.deep.equal [1, 2, 3]


  describe 'helpers', ->

    describe 'traits', ->
      beforeEach ->
        Factory.define 'traits', ->
          traits: @traits

      it 'delivers traits to the callback', ->
        result = Factory.create 'something-with-traits'
        result.traits.should.deep.equal ['something', 'with']

    describe '#is', ->

      it 'checks if trait is set', ->
        Factory.define 'hasTrait', ->
          @is('hello')

        Factory.create('hello-hasTrait').should.be.ok
        Factory.create('bye-hasTrait').should.not.be.ok
        Factory.create('bye-other-hello-somewhere-hasTrait').should.be.ok

    describe '#trait', ->

      beforeEach ->
        Factory.define 'trait', ->
          @trait('red', 'green', 'refactor')

      it 'returns undefined if no values match', ->
        expect(Factory.create('refgreen-trait')).to.be.undefined

      it 'returns one of the provided trait values', ->
        Factory.create('green-trait').should.equal 'green'
        Factory.create('red-trait').should.equal 'red'

      it 'returns the first encountered if multiple values match', ->
        Factory.create('green-red-trait').should.equal 'green'
        Factory.create('refactor-green-trait').should.equal 'refactor'

    describe 'sequence', ->

      beforeEach ->
        Factory.define 'counter', ->
          @sequence('property')

        Factory.define 'otherCounter', ->
          @sequence('property')

        Factory.define 'abc', ->
          @sequence((c) -> ['a', 'b', 'c'][c])

      it 'provides sequencers scoped to factory and property', ->
        Factory.create('counter').should.equal 0
        Factory.create('otherCounter').should.equal 0
        Factory.create('counter').should.equal 1

      it 'can yield results', ->
        Factory.create('abc').should.equal 'a'
        Factory.create('abc').should.equal 'b'

    describe 'sample', ->

      beforeEach ->
        Factory.define 'sampling', ->
          @sample('henk', 'piet', 'kees')

      afterEach ->
        @mathStub?.restore()

      it 'returns one of the provided values', ->
        @mathStub = sinon.stub Math, 'random', -> 0.01
        Factory.create('sampling').should.eql 'henk'

      it 'uses random to decide value', ->
        @mathStub = sinon.stub Math, 'random', -> 0.99
        Factory.create('sampling').should.eql 'kees'


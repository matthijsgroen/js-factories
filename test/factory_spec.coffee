
describe 'Factory', ->

  beforeEach ->
    Factory.define 'testFactSpecUser', (args...) ->
      args: args

  afterEach ->
    Factory.resetFactories()

  describe '::define', ->

    it 'registers a factory', ->
      result = Factory.create 'testFactSpecUser'
      expect(result.args).to.deep.equal []

    it 'raises an error on existing factory', ->
      expect(-> Factory.define('testFactSpecUser', ->)).to.throw 'Factory testFactSpecUser is already defined'

    it 'raises an error on naming conflict with traits', ->
      expect(-> Factory.define('admin-user', ->)).to.throw 'Factory name \'admin-user\' can\'t use - in name. It clashes with the traits construct'

  describe '::create', ->

    it 'delivers options to the callback', ->
      result = Factory.create 'testFactSpecUser',
        hello: 'world'
        other: 'value'
      expect(result.args[0]).to.deep.equal { hello: 'world', other: 'value' }

    it 'accepts multiple arguments', ->
      result = Factory.create 'testFactSpecUser', 1, 2, 3
      expect(result.args).to.deep.equal [1, 2, 3]

  describe '::createList', ->
    beforeEach ->
      Factory.define 'testFactory', (args...) ->
        index: @sequence('index')

    afterEach ->
      Factory.resetFactories()

    it 'creates the amount of items as indicated', ->
      result = Factory.createList 10, 'testFactory',
        hello: 'world'
        other: 'value'
      expect(result.length).to.equal 10

    it 'creates all items in the list seperately', ->
      result = Factory.createList 10, 'testFactory',
        hello: 'world'
        other: 'value'
      expect(result[0].index).to.equal 0
      expect(result[9].index).to.equal 9

  describe 'helpers', ->

    describe 'traits', ->
      beforeEach ->
        Factory.define 'testFactSpecTraits', ->
          traits: @traits

      it 'delivers traits to the callback', ->
        result = Factory.create 'something-with-testFactSpecTraits'
        expect(result.traits).to.deep.equal ['something', 'with']

    describe '#is', ->

      it 'checks if trait is set', ->
        Factory.define 'hasTrait', ->
          @is('hello')

        expect(Factory.create('hello-hasTrait')).to.be.ok
        expect(Factory.create('bye-hasTrait')).to.not.be.ok
        expect(Factory.create('bye-other-hello-somewhere-hasTrait')).to.be.ok

    describe '#trait', ->

      beforeEach ->
        Factory.define 'testFactSpecTrait', ->
          @trait('red', 'green', 'refactor')

      it 'returns undefined if no values match', ->
        expect(Factory.create('refgreen-testFactSpecTrait')).to.be.undefined

      it 'returns one of the provided trait values', ->
        expect(Factory.create('green-testFactSpecTrait')).to.equal 'green'
        expect(Factory.create('red-testFactSpecTrait')).to.equal 'red'

      it 'returns the first encountered if multiple values match', ->
        expect(Factory.create('green-red-testFactSpecTrait')).to.equal 'green'
        expect(Factory.create('refactor-green-testFactSpecTrait')).to.equal 'refactor'

    describe 'sequence', ->

      beforeEach ->
        Factory.define 'counter', ->
          @sequence('property')

        Factory.define 'otherCounter', ->
          @sequence('property')

        Factory.define 'abc', ->
          @sequence((c) -> ['a', 'b', 'c'][c])

      it 'provides sequencers scoped to factory and property', ->
        expect(Factory.create('counter')).to.equal 0
        expect(Factory.create('otherCounter')).to.equal 0
        expect(Factory.create('counter')).to.equal 1

      it 'can yield results', ->
        expect(Factory.create('abc')).to.equal 'a'
        expect(Factory.create('abc')).to.equal 'b'

    describe 'sample', ->

      beforeEach ->
        Factory.define 'sampling', ->
          @sample('henk', 'piet', 'kees')

      afterEach ->
        @mathStub?.restore()

      it 'returns one of the provided values', ->
        @mathStub = sinon.stub Math, 'random', -> 0.01
        expect(Factory.create('sampling')).to.eql 'henk'

      it 'uses random to decide value', ->
        @mathStub = sinon.stub Math, 'random', -> 0.99
        expect(Factory.create('sampling')).to.eql 'kees'


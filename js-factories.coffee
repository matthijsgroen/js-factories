((name, context, factory) ->
  # Module systems magic dance.
  if (typeof require == "function" && typeof exports == "object" && typeof module == "object")
    # NodeJS
    module.exports = factory()
  else if (typeof define == "function" && define.amd)
    # AMD
    define -> factory()
  else
    # Other environment (usually <script> tag)
    context[name] = factory()

)('Factory', this, ->

  sequencer = (property) ->
    value = if @sequences[property]?
      @sequences[property] += 1
    else
      @sequences[property] = 0
    if typeof(property) is 'function'
      property(value)
    else
      value

  Factory =
    factories: {}

    define: (factoryName, builder) ->
      if factoryName.indexOf('-') > 0
        throw new Error "Factory name '#{factoryName}' can't use - in name. It clashes with the traits construct"
      if @factories[factoryName]?
        throw new Error "Factory #{factoryName} is already defined"
      @factories[factoryName] =
        sequences: {}
        factory: builder

    create: (nameWithTraits, args...) ->
      traits = nameWithTraits.split '-'
      factoryName = traits.pop()
      unless @factories[factoryName]?
        throw new Error "Factory #{factoryName} does not exist"

      f = @factories[factoryName]
      obj =
        sequences: f.sequences
        factory: f.factory
        sequence: sequencer
        traits: traits
        is: (name) -> ~@traits.indexOf(name)
        trait: (names...) ->
          for name in @traits
            return name if ~names.indexOf(name)
        sample: (values...) ->
          values[Math.floor(Math.random() * values.length)]

      r = obj.factory args...
      f.sequences = obj.sequences
      obj = null
      r

    createList: (amount, args...) ->
      @create(args...) for i in [1..amount]

    resetFactories: ->
      @factories = []

  Factory
)

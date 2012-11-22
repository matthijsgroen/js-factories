
sequencer = (property) ->
  value = if @sequences[property]?
    @sequences[property] += 1
  else
    @sequences[property] = 0
  if typeof(property) is 'function'
    property(value)
  else
    value

window.Factory =
  factories: {}

  define: (factoryName, builder) ->
    if factoryName.indexOf('-') > 0
      throw "Factory name '#{factoryName}' can't use - in name. It clashes with the traits construct"
    if @factories[factoryName]?
      throw "Factory #{factoryName} is already defined"
    @factories[factoryName] =
      sequences: {}
      factory: builder

  create: (nameWithTraits, args...) ->
    traits = nameWithTraits.split '-'
    factoryName = traits.pop()
    unless @factories[factoryName]?
      throw "Factory #{factoryName} does not exist"

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

  resetFactories: ->
    @factories = []




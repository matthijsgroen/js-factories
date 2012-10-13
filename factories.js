(function() {
  var sequencer,
    __slice = Array.prototype.slice;

  sequencer = function(property) {
    var value;
    value = this.sequences[property] != null ? this.sequences[property] += 1 : this.sequences[property] = 0;
    if (typeof property === 'function') {
      return property(value);
    } else {
      return value;
    }
  };

  window.Factory = {
    factories: {},
    define: function(factoryName, builder) {
      if (factoryName.indexOf('-') > 0) {
        throw "Factory name '" + factoryName + "' can't use - in name. It clashes with the traits construct";
      }
      if (this.factories[factoryName] != null) {
        throw "Factory " + factoryName + " is already defined";
      }
      return this.factories[factoryName] = {
        sequences: {},
        factory: builder
      };
    },
    create: function() {
      var args, f, factoryName, nameWithTraits, obj, r, traits;
      nameWithTraits = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      traits = nameWithTraits.split('-');
      factoryName = traits.pop();
      if (this.factories[factoryName] == null) {
        throw "Factory " + factoryName + " does not exist";
      }
      f = this.factories[factoryName];
      obj = {
        sequences: f.sequences,
        factory: f.factory,
        sequence: sequencer,
        traits: traits,
        is: function(name) {
          return ~this.traits.indexOf(name);
        },
        trait: function() {
          var name, names, _i, _len, _ref;
          names = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          _ref = this.traits;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            name = _ref[_i];
            if (~names.indexOf(name)) return name;
          }
        },
        sample: function() {
          var values;
          values = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return values[Math.floor(Math.random() * values.length)];
        }
      };
      r = obj.factory.apply(obj, args);
      f.sequences = obj.sequences;
      obj = null;
      return r;
    },
    resetFactories: function() {
      return this.factories = [];
    }
  };

}).call(this);

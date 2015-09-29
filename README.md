js-factories
============

[![Build Status](https://travis-ci.org/matthijsgroen/js-factories.png?branch=master)](https://travis-ci.org/matthijsgroen/js-factories)
[![NPM Version](https://fury-badge.herokuapp.com/js/js-factories.png)](http://badge.fury.io/js/js-factories)


js-factories is a library to use dynamic fixtures using Factories in
javascript/coffeescript. Ideal to combine using [Mocha](http://visionmedia.github.com/mocha/)/[chai](http://chaijs.com/) frameworks and test rich classes for MV\*\* Frameworks like [Backbone.js](http://backbonejs.org/)

Usage
-----

Include `js-factories.js` in your test suite.

Factory support is added to quickly be able to build models or
other objects as you see fit:

```coffee
Factory.define 'user', (attributes = {}) ->
  new User attributes

Factory.create 'user', name: 'Matthijs'
Factory.createList 10, 'user', name: 'Matthijs'
```

### Traits

you can also use 'traits'.
Traits are flags that are set when the user calls create with the
factory name prefixed with terms separated by dashes.

Like: 'female-admin-user'

This will call the 'user' factory, and provide the terms 'female' and
'admin' as traits for this user

this list is accessible in the factory callback using `this.traits`

There are 2 helper methods to help check if traits are set:

```javascript
this.trait('returns', 'one', 'of', 'these', 'values')
```

and

```javascript
this.is('admin') // returns a boolean value
```

Extended example:

```javascript
  Factory.define('user', function(attributes) {
    var returningClass;
    if (attributes == null) {
      attributes = {};
    }
    attributes.gender = this.trait('male', 'female') || 'male';
    returningClass = User;
    if (this.is('admin')) {
      returningClass = AdminUser;
    }
    return new returningClass(attributes);
  });
  
  Factory.create('user', { name: 'Matthijs' }) // => new User name: 'Matthijs'
  Factory.create('male-user', { name: 'Matthijs' }) // => new User name: 'Matthijs', gender: 'male'
  Factory.create('male-admin-user', { name: 'Matthijs' }) // => new AdminUser name: 'Matthijs', gender: 'male'
  Factory.create('female-user', { name: 'Beppie' }) // => new User name: 'Beppie', gender: 'female'
```

### Sequences

Sequences are also supported:

```javascript
  Factory.define('counter', function() {
    return {
      amount: this.sequence('amount'),
      other: this.sequence('other')
    };
  });
```

This does not conflict with similar names in other factory definitions.

You can also yield results:

```javascript
  Factory.define('abc', function() {
    return this.sequence(function(i) {
      return ['a', 'b', 'c'][i];
    });
  });

  // results in:
  Factory.create('abc') // => 'a'
  Factory.create('abc') // => 'b'
```

### Sampling

You can sample a value from a list

```javascript
  Factory.define('sampler', function() {
    return this.sample('a', 'b', 'c');
  });
```

Will randomly return a, b or c every time

## License

Copyright (c) 2012-2014 Matthijs Groen

MIT License (see the LICENSE file)

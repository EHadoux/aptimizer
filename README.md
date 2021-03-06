#Aptimizer [![DOI](https://zenodo.org/badge/7153/EHadoux/aptimizer.svg)](http://dx.doi.org/10.5281/zenodo.17034)

[![Build Status](https://img.shields.io/travis/EHadoux/aptimizer.svg?branch=master)](https://travis-ci.org/EHadoux/aptimizer) [![Code Climate](https://img.shields.io/codeclimate/github/EHadoux/aptimizer.svg)](https://codeclimate.com/github/EHadoux/aptimizer) [![Test Coverage](https://img.shields.io/codeclimate/coverage/github/EHadoux/arg2momdp.svg)](https://codeclimate.com/github/EHadoux/aptimizer) [![Dependency Status](https://img.shields.io/gemnasium/EHadoux/aptimizer.svg)](https://gemnasium.com/EHadoux/aptimizer) [![Inline docs](http://inch-ci.org/github/EHadoux/aptimizer.svg?branch=master)](http://inch-ci.org/github/EHadoux/aptimizer) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/EHadoux/aptimizer/master)



This gem parses and converts a probabilistic argumentation problem [1] to a Mixed-Observability Markov Decision Process (MOMDP) [2].

The input is defined in the following part. The output can be of two types :

- [ ] Cassandra's [POMDP file format](http://www.pomdp.org/code/pomdp-file-spec.shtml)
- [x] [POMDPX file format](http://bigbird.comp.nus.edu.sg/pmwiki/farm/appl/index.php?n=Main.PomdpXDocumentation)

The file can then be processed with the algorithm of your choice.

[1]: Anthony Hunter, _Probabilistic Strategies in Dialogical Argumentation_, SUM 2014

[2]: Sylvie C. W. Ong, Shao Wei Png, David Hsu, Wee Sun Lee, _Planning under Uncertainty for Robotic Tasks with Mixed Observability_, IJR 2010

##Input format
In all the input strings, spaces are not read, i.e., ```a,b``` is equivalent to ```a, b```.
###Arguments
Arguments are represented by a list of lowcase letters (```a```) or words (```aaaaaa```)

###Attacks
Attacks are a list of ```e``` predicates applied on two arguments, separated by a comma, e.g. ```e(a,bb)```

###Goals
Goals are a list of ```g``` predicates applied to one argument, separated by ampersands (```&```). 
Anti-goals, arguments to avoid being in the public space, are also supported using ```!g```. 
If anti-goals are specified, they must be all grouped after the goals specification, e.g. ```g(a) & g(b) & !g(c) & !g(d)```.

###Predicates
There are three kinds of predicates:

1. Attacks (see above)
2. Publicly exposed arguments: predicate ```a``` applied to one argument, e.g. ```a(a)```
3. Private arguments: predicate ```h``` applied to one argument, e.g. ```h(a)```

###Modifiers
Those predicates can be modified (added or removed from the public space or a private state).

- Only attacks and public exposition can be added to or removed from the public space, e.g. ```+e(a,b)``` or ```-a(c)```
- Only private arguments can be added to or removed from the private state of an agent, e.g. ```.+h(a)``` or ```.-h(c)```

###Rules 
Two sets of rules have to be specified: one for the agent to optimize and one for the opponent. 
The former will be automatically cut into actions (thus removing the probabilities) if it not has been already done. 
The later will be left untouched.
A rule is composed of a list of predicates (the premisses) separated by ampersands, an arrow ```=>``` and a list of alternatives separated by the pipe character (```|```).

An alternative is composed of a probability, a colon and a list of modifiers separated by ampersands.
If the probability is 1 (only one alternative for the rule) it must be specified.

Example: ```h(b) & a(f) => 0.8: +a(e) & +e(e,g) | 0.2: +a(d) & +e(d,a)```

The sets of rules are composed by rules, separated by commas.

###Initial state
The initial state can be specified as a list of predicates, similarly to rule premisses.
All unspecified predicates are supposed to be false.

###See examples for more use cases

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aptimizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aptimizer

## Usage

Call ```aptimizer``` without argument to see the help screen.

## Contributing

1. Fork it ( https://github.com/EHadoux/aptimizer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

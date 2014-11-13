#arg2momdp

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
Arguments are represented by a list of lowcase letters (```a```) or words (```aaaaaa```) separated by a comma, e.g. ```a, bb, ccc,d```

###Attacks
Attacks are a list of ```e``` predicates applied on two arguments, separated by a comma, e.g. ```e(a,bb), e(ccc, bb), e(d,a)```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arg2momdp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arg2momdp

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/EHadoux/arg2momdp/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

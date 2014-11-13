# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arg2momdp/version'

Gem::Specification.new do |spec|
  spec.name          = "arg2momdp"
  spec.version       = Arg2MOMDP::VERSION
  spec.authors       = ["Emmanuel Hadoux"]
  spec.email         = ["emmanuel.hadoux@gmail.com"]
  spec.summary       = %q{arg2momdp transforms a probabilistic argumentation problem
                        to a MOMDP}
  spec.description   = %q{arg2momdp transforms a probabilistic argumentation problem
                        to a MOMDP}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rltk", "~> 3.0"
  spec.add_dependency "nokogiri", "~> 1.6"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end

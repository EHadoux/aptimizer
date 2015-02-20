# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aptimizer/version"

Gem::Specification.new do |spec|
  spec.name          = "aptimizer"
  spec.version       = Aptimizer::VERSION
  spec.authors       = ["Emmanuel Hadoux"]
  spec.email         = ["emmanuel.hadoux@gmail.com"]
  spec.summary       = %q{aptimizer optimizes APS and transforms it to be solved}
  spec.description   = %q{aptimizer optimizes APS and transforms it to be solved}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "rltk"
  spec.add_dependency "thor"
end

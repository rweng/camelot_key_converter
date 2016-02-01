# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'camelot_key_converter/version'

Gem::Specification.new do |spec|
  spec.name          = "camelot_key_converter"
  spec.version       = CamelotKeyConverter::VERSION
  spec.authors       = ["Robin Wenglewski"]
  spec.email         = ["robin@wenglewski.de"]

  spec.summary       = %q{tool to convert keys in mp3s}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/rweng/camelot_key_converter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "hashie"
  spec.add_dependency "pry"
  spec.add_dependency "highline"
  spec.add_dependency "taglib-ruby", '~> 0.7.1'
end

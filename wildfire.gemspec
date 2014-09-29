# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wildfire/version'

Gem::Specification.new do |spec|
  spec.name          = 'wildfire'
  spec.version       = Wildfire::VERSION
  spec.authors       = ['Domas']
  spec.email         = ['domas.bitvinskas@me.com']
  spec.summary       = %q(Cut objects from images.)
  spec.description   = %q(Uses computer vision to cut objects from images.)
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ['wildfire']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'andand', '~> 1.3'
  spec.add_runtime_dependency 'pry', '~> 0.9'
  spec.add_runtime_dependency 'pry-stack_explorer', '~> 0.4'
  spec.add_runtime_dependency 'ropencv', '~> 0.0.17'
  spec.add_runtime_dependency 'require_all', '~> 1.3'
  spec.add_runtime_dependency 'memoist'
  spec.add_runtime_dependency 'slop', '~> 3.4'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end

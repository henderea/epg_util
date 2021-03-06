# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epg_util/version'

Gem::Specification.new do |spec|
  spec.name          = 'epg_util'
  spec.version       = EpgUtil::VERSION
  spec.authors       = ['Eric Henderson']
  spec.email         = ['henderea@gmail.com']
  spec.summary       = %q{Various commands for epg}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.3'

  spec.add_dependency 'everyday-cli-utils', '~> 1.8', '>= 1.8.7.2'
  spec.add_dependency 'everyday-plugins', '~> 1.2', '>= 1.2.2'
  spec.add_dependency 'everyday_natsort', '~> 1.0', '>= 1.0.4'
  spec.add_dependency 'rbe', '~> 5.3', '>= 5.3.1'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'interswitch/version'

Gem::Specification.new do |spec|
  spec.name          = "interswitch"
  spec.version       = InterswitchVersion::VERSION
  spec.authors       = ["Nnaemeka.Okoroafor"]
  spec.email         = ["nnaemeka.okoroafor@interswitchgroup.com"]

  spec.summary       = %q{Perform common actions for interacting with Interswitch payment systems}
  spec.description   = %q{A utility gem for basic interswitch payment functionalities}
  spec.homepage      = 'https://github.com/techquest/interswitch_ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.test_files    = `git ls-files -- test/*`.split("\n")

  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'addressable'
  spec.add_development_dependency 'rest-client'
  spec.add_development_dependency 'mocha'
  spec.add_runtime_dependency 'addressable'
  spec.add_runtime_dependency 'rest-client'
  spec.add_runtime_dependency 'oauth2'

end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'surrogator/uploader/version'

Gem::Specification.new do |spec|
  spec.name          = "surrogator-uploader"
  spec.version       = Surrogator::Uploader::VERSION
  spec.authors       = ["tohrinagi"]
  spec.email         = ["tohrinagi@gmail.com"]
  spec.summary       = %q{uploader for surrogator icon.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/tohrinagi/surrogator-uploader"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra",  "~> 1.4.6"
  spec.add_dependency "haml",     "~> 4.0.6"
  spec.add_dependency "inifile",  "~> 3.0.0"
  spec.add_dependency "ruby-net-ldap",  "~> 0.0.4"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end

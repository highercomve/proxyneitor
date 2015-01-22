# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proxyneitor/version'

Gem::Specification.new do |spec|
  spec.name          = "proxyneitor"
  spec.version       = Proxyneitor::VERSION
  spec.authors       = ["Sergio Marin"]
  spec.email         = ["higher.vnf@gmail.com"]
  spec.summary       = %q{Build nginx.conf files for proxy your development environment}
  spec.description   = %q{Build nginx.conf files for proxy}
  spec.homepage      = "https://github.com/highercomve/proxyneitor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ['proxyneitor']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor', "~>0.19.1"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

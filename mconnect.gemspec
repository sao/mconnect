# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mconnect/version'

Gem::Specification.new do |spec|
  spec.name          = "mconnect"
  spec.version       = Mconnect::VERSION
  spec.authors       = ["Silas Sao"]
  spec.email         = ["silassao@gmail.com"]
  spec.summary       = "Gem for the MasteryConnect API"
  spec.description   = "Gem created to convert MasteryConnect API endpoints to CSV"
  spec.homepage      = "http://silassao.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor",  "~> 0.19"
  spec.add_dependency "oauth", "~> 0.4"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

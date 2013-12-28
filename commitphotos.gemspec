# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commitphotos/version'

Gem::Specification.new do |spec|
  spec.name          = "commitphotos"
  spec.version       = Commitphotos::VERSION
  spec.authors       = ["Colby Aley", "Jackson Gariety"]
  spec.email         = ["colby@aley.me", "Jackson Gariety"]
  spec.description   = "Take a photo of yourself every time you commit and show it to the world."
  spec.summary       = "A photo or gif on every commit."
  spec.homepage      = "http://commitphotos.com/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_runtime_dependency "mini_magick"
  spec.add_runtime_dependency "active_support"
  spec.add_runtime_dependency "rvideo"
  spec.add_runtime_dependency "choice"
  spec.add_runtime_dependency "rest-client"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

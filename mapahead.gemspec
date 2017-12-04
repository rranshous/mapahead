# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "mapahead"
  spec.version       = "0.0.1"
  spec.authors       = ["Robby"]
  spec.email         = ["robby.ranshous@coxautoinc.com"]
  spec.summary       = "work ahead in the stream"
  spec.description   = "work ahead in the stream"
  spec.homepage      = ""
  spec.license       = ""

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end

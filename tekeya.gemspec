# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tekeya/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Omar Mekky"]
  gem.email         = ["omar.mekky@mashsolvents.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tekeya"
  gem.require_paths = ["lib"]
  gem.version       = Tekeya::VERSION

  gem.add_dependency  'redis', '~> 3.0.1'
  gem.add_dependency  'rebat', '~> 0.1.0'
  gem.add_dependency  'orm_adapter', '~> 0.4'
  gem.add_dependency  'railties', '~> 3.1'
end

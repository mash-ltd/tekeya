# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tekeya/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Omar Mekky", "Khaled Gomaa"]
  gem.email         = ["omar.mekky@mashsolvents.com", "khaled.gomaa@mashsolvents.com"]
  gem.description   = %q{a social engine for Rails applications based on Redis and RebatDB}
  gem.summary       = %q{a social engine for Rails applications based on Redis and RebatDB.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tekeya"
  gem.require_paths = ["lib"]
  gem.version       = Tekeya::VERSION

  gem.add_dependency  'redis', '~> 3.0.1'
  gem.add_dependency  'rebat', '~> 0.1.4'
  gem.add_dependency  'resque', '~> 1.23.0'
  gem.add_dependency  'railties', '~> 3.1'
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slugable/version'

Gem::Specification.new do |gem|
  gem.name          = 'slugable'
  gem.version       = Slugable::VERSION
  gem.authors       = ['Miroslav Hettes']
  gem.email         = ['hettes@webynamieru.sk']
  gem.description   = %q{Add dsl method for automatic storing seo friendly url in database column}
  gem.summary       = %q{Storing seo friendly url in column}
  gem.homepage      = 'https://github.com/mirrec/slugable'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'activerecord', '>= 3.0'
  gem.add_runtime_dependency 'activesupport', '>= 3.0'
  gem.add_runtime_dependency 'wnm_support', '~> 0.0.4'

  gem.add_development_dependency 'rspec', '~> 3.4.0'
  gem.add_development_dependency 'rake', '~> 0.9.2.2'
  gem.add_development_dependency 'sqlite3', '~> 1.3.6'
  gem.add_development_dependency 'ancestry', '~> 1.3.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'codeclimate-test-reporter'
end

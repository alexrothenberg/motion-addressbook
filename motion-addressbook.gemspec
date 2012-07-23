# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion-addressbook/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alex Rothenberg"]
  gem.email         = ["alex@alexrothenberg.com"]
  gem.description   = %q{A RubyMotion wrapper around the iOS Address Book framework}
  gem.summary       = %q{A RubyMotion wrapper around the iOS Address Book framework}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "motion-addressbook"
  gem.require_paths = ["lib"]
  gem.version       = Motion::Addressbook::VERSION
  
  gem.add_dependency 'bubble-wrap'
  gem.add_development_dependency 'rake'  
  gem.add_development_dependency 'rspec'
end

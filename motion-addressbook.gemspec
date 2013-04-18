# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion-addressbook/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "motion-addressbook"
  gem.version       = Motion::Addressbook::VERSION

  gem.authors       = ["Alex Rothenberg", "Jason May"]
  gem.email         = ["alex@alexrothenberg.com", "jmay@pobox.com"]
  gem.description   = %q{A RubyMotion wrapper around the iOS Address Book framework}
  gem.summary       = %q{A RubyMotion wrapper around the iOS Address Book framework}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'bubble-wrap'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end

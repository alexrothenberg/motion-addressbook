require "bundler/gem_tasks"
$:.unshift("/Library/RubyMotion/lib")
if ENV['osx']
  require 'motion/project/template/osx'
else
  require 'motion/project/template/ios'
end
Bundler.setup
Bundler.require

# require 'bubble-wrap/test'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'AddressBook'
end

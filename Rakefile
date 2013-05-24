require "bundler/gem_tasks"
$:.unshift("/Library/RubyMotion/lib")
if ENV['osx']
  require 'motion/project/template/osx'
else
  require 'motion/project/template/ios'
end
Bundler.setup
Bundler.require

unless ENV['osx']
  # iOS needs an AppDelegate for REPL to launch; steal one from BW
  require 'bubble-wrap/test'
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'AddressBook'

  if Motion::Project::App.osx?
    app.specs_dir = "./spec/osx"
  else
    app.specs_dir = "./spec/ios"
  end
end

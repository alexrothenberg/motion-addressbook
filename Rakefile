#!/usr/bin/env rake
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require "bundler/gem_tasks"
Bundler.setup
Bundler.require

require 'bubble-wrap/test'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'AddressBook'
end

require "motion-addressbook/version"

# RubyMotion bug RM-81 was fixed for 2.8; motion-addressbook
if Gem::Version.new(Motion::Version) < Gem::Version.new("2.8")
  raise <<EOT
motion-addressbook requires at least RubyMotion version 2.8.

If you cannot upgrade RubyMotion please use an older version of this gem.
Add the following to your Gemfile:

gem 'motion-addressbook', '<= 1.5.0'

EOT
end

lib_dir_path = File.dirname(File.expand_path(__FILE__))
Motion::Project::App.setup do |app|

  app.frameworks += ['AddressBook']
  app.files.unshift(Dir.glob(File.join(lib_dir_path, "../motion/address_book.rb")))

  if app.respond_to?(:template) && app.template == :osx
    # We have an OS X project
    app.files.unshift(Dir.glob(File.join(lib_dir_path, "../motion/address_book/osx/**.rb")))
  else
    # We have an iOS project
    app.frameworks += ['AddressBookUI']
    app.files.unshift(Dir.glob(File.join(lib_dir_path, "../motion/address_book/ios/**.rb")))
  end
end

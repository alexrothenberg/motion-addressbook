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

BubbleWrap.require 'motion/address_book.rb' do
  file('motion/address_book.rb').uses_framework('AddressBook')
end

BubbleWrap.require_ios do
  # BW.require 'motion/address_book/multi_value.rb'
  BW.require 'motion/address_book/ios/addr_book.rb'
  BW.require 'motion/address_book/ios/person.rb'
  BW.require 'motion/address_book/ios/group.rb'
  BW.require 'motion/address_book/ios/multi_valued.rb'
  BW.require 'motion/address_book/ios/source.rb'

  # This is an iOS-specific RubyMotion bug workaround.
  # Motion::Project::App.setup do |app|
  #   app.vendor_project(File.expand_path(File.join(File.dirname(__FILE__), '../abhack')), :static)
  # end

  BW.require 'motion/address_book/ios/picker.rb' do
    file('motion/address_book/ios/picker.rb').uses_framework('AddressBookUI')
  end
end

BubbleWrap.require_osx do
  BW.require 'motion/address_book/osx/addr_book.rb'
  BW.require 'motion/address_book/osx/person.rb'
  BW.require 'motion/address_book/osx/group.rb'
  BW.require 'motion/address_book/osx/multi_valued.rb'
  BW.require 'motion/address_book/osx/source.rb'
end

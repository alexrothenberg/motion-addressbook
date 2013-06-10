require "motion-addressbook/version"

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
  Motion::Project::App.setup do |app|
    app.vendor_project(File.expand_path(File.join(File.dirname(__FILE__), '../abhack')), :static)
  end

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

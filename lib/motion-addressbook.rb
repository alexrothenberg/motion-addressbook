require "motion-addressbook/version"

BubbleWrap.require 'motion/address_book.rb' do
  file('motion/address_book.rb').uses_framework('AddressBook')
end
# BW.require 'motion/address_book/multi_value.rb'
BW.require 'motion/address_book/addr_book.rb'
BW.require 'motion/address_book/person.rb'
BW.require 'motion/address_book/group.rb'
BW.require 'motion/address_book/multi_valued.rb'
BW.require 'motion/address_book/source.rb'

BubbleWrap.require_ios do
  Motion::Project::App.setup do |app|
    app.vendor_project(File.expand_path(File.join(File.dirname(__FILE__), '../abhack')), :static)
  end

  BW.require 'motion/address_book/picker.rb' do
    file('motion/address_book/picker.rb').uses_framework('AddressBookUI')
  end
end

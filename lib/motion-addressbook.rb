require "motion-addressbook/version"

BubbleWrap.require 'motion/address_book.rb' do
  file('motion/address_book.rb').uses_framework('AddressBook')
end
BW.require 'motion/address_book/multi_value.rb'
BW.require 'motion/address_book/multi_valued.rb'
BW.require 'motion/address_book/person.rb'
BW.require 'motion/address_book/picker.rb' do
  file('motion/address_book/picker.rb').uses_framework('AddressBookUI')
end

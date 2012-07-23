# Addressbook for RubyMotion

A RubyMotion wrapper around the iOS Address Book framework for RubyMotion apps.

Apple's [Address Book Programming Guide for iOS](http://developer.apple.com/library/ios/#DOCUMENTATION/ContactData/Conceptual/AddressBookProgrammingGuideforiPhone/Introduction.html)

## Installation

Add this line to your application's Gemfile:

    gem 'motion-addressbook'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motion-addressbook

## Usage

### List all people

```ruby
    AddressBook::Person.all
    # => [#<AddressBook::Person:0x6d55e90 @attributes={:first_name=>"Alex", :last_name=>"Rothenberg", :job_title=>nil, :department=>nil, :organization=>nil} @ab_person=#<__NSCFType:0x6df8bf0>>,
    #     #<AddressBook::Person:0x6d550a0 @attributes={:first_name=>"Laurent", :last_name=>"Sansonetti", :job_title=>nil, :department=>nil, :organization=>"HipByte"} @ab_person=#<__NSCFType:0x6df97d0>>]
```


### Create a new Contact and save in Contacts app

```ruby
    alex = AddressBook::Person.new(:first_name => 'Alex', :last_name => 'Rothenberg', :email => 'alex@example.com')
    alex.save
```

### Get an existing Contact

```ruby
    alex = AddressBook::Person.new(:first_name => 'Alex', :email => 'alex@example.com')
    alex.last_name
    # => 'Rothenberg'
```

### Update existing contact

```ruby
    alex = AddressBook::Person.new(:first_name => 'Alex', :email => 'alex@example.com')
    alex.job_title = 'RubyMotion Developer'
    alex.save
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

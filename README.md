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

### Requesting access

iOS 6 requires asking the user for permission before it allows an app to access the AddressBook.  There are 3 ways to interact with this

1 - Let the gem take care of it for you

```ruby
people = AddressBook::Person.all
# A dialog may be presented to the user before "people" was returned
```

2 - Manually decide when to ask the user for authorization

```ruby
# asking whether we are already authorized
if AddressBook.authorized?
  puts "This app is authorized?"
else
  puts "This app is not authorized?"
end

# ask the user to authorize us
if AddressBook.authorize
  # do something now that the user has said "yes"
else
  # do something now that the user has said "no"
end
```

3 - Manually ask the user but do it asynchronously (this is how Apple's API works)

```ruby
# ask the user to authorize us
if AddressBook.authorize do |granted|
  # this block is invoked sometime later
  if granted
    # do something now that the user has said "yes"
  else
    # do something now that the user has said "no"
  end
end
# do something here before the user has decided
```

### Instantiating a person object

There are 3 ways to instantiate a person object

### To get a new person not yet connected to the iOS Address Book

```ruby
AddressBook::Person.new
# => #<AddressBook::Person:0x8c67ca0 @attributes={:first_name=>nil, :last_name=>nil, :job_title=>nil, :department=>nil, :organization=>nil} @new_record=true @ab_person=#<__NSCFType:0x6d832e0>>
```

### To get a list of existing people from the iOS Address Book

Get all people with `.all`

```ruby
AddressBook::Person.all
# => [#<AddressBook::Person:0x6d55e90 @attributes={:first_name=>"Alex", :last_name=>"Rothenberg", :job_title=>nil, :department=>nil, :organization=>nil} @ab_person=#<__NSCFType:0x6df8bf0>>,
#     #<AddressBook::Person:0x6d550a0 @attributes={:first_name=>"Laurent", :last_name=>"Sansonetti", :job_title=>nil, :department=>nil, :organization=>"HipByte"} @ab_person=#<__NSCFType:0x6df97d0>>]
```

Get a list of all people matching one attribute with `.find_all_by_XXX`

```ruby
AddressBook::Person.find_all_by_email('alex@example.com')
# => [#<AddressBook::Person:0x6d55e90 @attributes={:first_name=>"Alex", :last_name=>"Rothenberg", :job_title=>nil, :department=>nil, :organization=>nil} @ab_person=#<__NSCFType:0x6df8bf0>>]
```

Get the first person matching one attribute with `find_by_XXX`

```ruby
AddressBook::Person.find_by_email('alex@example.com')
# => #<AddressBook::Person:0x6d55e90 @attributes={:first_name=>"Alex", :last_name=>"Rothenberg", :job_title=>nil, :department=>nil, :organization=>nil} @ab_person=#<__NSCFType:0x6df8bf0>>
```

Get a list of all people matching several attributes with `.where`

```ruby
AddressBook::Person.where(:email => 'alex@example.com', :first_name => 'Alex')
# => [#<AddressBook::Person:0x6d55e90 @attributes={:first_name=>"Alex", :last_name=>"Rothenberg", :job_title=>nil, :department=>nil, :organization=>nil} @ab_person=#<__NSCFType:0x6df8bf0>>]
```

To look for an existing person or get a new one if none is found `find_or_new_by_XXX`

```ruby
AddressBook::Person.find_or_new_by_email('alex@example.com')
# => #<AddressBook::Person:0xe4e3a80 @attributes={:first_name=>"Alex", :last_name=>"Rothenberg", :job_title=>nil, :department=>nil, :organization=>nil} @ab_person=#<__NSCFType:0xe4bbef0>>
```

### Create a new Contact and save in Contacts app

```ruby
AddressBook::Person.create(:first_name => 'Alex', :last_name => 'Rothenberg', :email => 'alex@example.com')
# => #<AddressBook::Person:0xe4e3a80 @attributes={:first_name=>"Alex", :last_name=>"Rothenberg", :job_title=>nil, :department=>nil, :organization=>nil} @ab_person=#<__NSCFType:0xe4bbef0>>
```

### Update existing contact

```ruby
alex = AddressBook::Person.find_by_email('alex@example.com')
alex.job_title = 'RubyMotion Developer'
alex.save
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

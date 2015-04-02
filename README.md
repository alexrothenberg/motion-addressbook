# Addressbook for RubyMotion

[![Build Status](https://secure.travis-ci.org/alexrothenberg/motion-addressbook.png)](http://travis-ci.org/alexrothenberg/motion-addressbook)
[![Code Climate](https://codeclimate.com/github/alexrothenberg/motion-addressbook.png)](https://codeclimate.com/github/alexrothenberg/motion-addressbook)
[![Gem Version](https://badge.fury.io/rb/motion-addressbook.png)](http://badge.fury.io/rb/motion-addressbook)

A RubyMotion wrapper around the iOS and OSX Address Book frameworks for RubyMotion apps.

Apple's Address Book Programming Guide for [iOS](http://developer.apple.com/library/ios/#DOCUMENTATION/ContactData/Conceptual/AddressBookProgrammingGuideforiPhone/Introduction.html)
or for [OSX](https://developer.apple.com/library/mac/#documentation/userexperience/Conceptual/AddressBook/AddressBook.html#//apple_ref/doc/uid/10000117i)

## Installation

### If you're using `bundler` (this is recommended):

Add these lines to your application's `Rakefile`:

    require 'bundler'
    Bundler.require

Add this line to your application's `Gemfile`:

    gem 'motion-addressbook'

And then execute:

    $ bundle

### Manually without bundler

Or install it yourself (remember to add the bubble-wrap dependency) as:

    $ gem install bubble-wrap
    $ gem install motion-addressbook

## Usage

### Requesting access

iOS 6/7 requires that the user give permission before it allows an app to access the AddressBook.

1 - Let the gem take care of it for you

```ruby
ab = AddressBook::AddrBook.new
# ...do something else...
people = ab.people
```

The `people` method will raise an exception if called while
authorization has not been granted.

2 - Manually decide when to ask the user for authorization

```ruby
# asking whether we are already authorized
if AddressBook.authorized?
  puts "This app is authorized!"
else
  puts "This app is not authorized!"
end

# ask the user to authorize us (blocking)
if AddressBook.request_authorization
  # do something now that the user has said "yes"
else
  # do something now that the user has said "no"
end
```

3 - Manually ask the user but do it asynchronously (this is how Apple's API works)

```ruby
# ask the user to authorize us
if AddressBook.request_authorization do |granted|
  # this block is invoked sometime later
  if granted
    # do something now that the user has said "yes"
  else
    # do something now that the user has said "no"
  end
end
# do something here before the user has decided
```

The iOS6 simulator does not demand AddressBook authorization. The iOS7
simulator does.

### Showing the ABPeoplePickerNavigationController

```ruby
AddressBook.pick do |person|
  if person
    # person is an AddressBook::Person object
  else
    # canceled
  end
end
```

You can also specify the presenting controller:

```ruby
AddressBook.pick presenter: self do |person|
  ...
end
```

### Showing the ABNewPersonViewController

```ruby
AddressBook.create do |person|
  if person
    # person is an AddressBook::Person object
  else
    # canceled
  end
end
```

### Working with Person objects

Get a list of existing people from the Address Book. On IOS, results
are sorted using the sort order (First/Last or Last/First) chosen by
the user in iOS Settings.

```ruby
ab = AddressBook::AddrBook.new
ab.people
=> [#<AddressBook::Person:3: {:first_name=>"John", :last_name=>"Appleseed", ...}>, ...]
```

Create a new Person and save to the Address Book.

Note that Person records can take multiple values for email addresses, phone
numbers, postal address, social profiles, and instant messaging
profiles.

```ruby
ab.create_person(:first_name => 'Alex', :last_name => 'Rothenberg', :emails => [{ :value => 'alex@example.com', :label => 'Home'}], :phones => [{ :value => '9920149993', :label => 'Mobile'}])
=> #<AddressBook::Person:7: {:first_name=>"Alex", :last_name=>"Rothenberg", ...}>
```

Construct a new blank Person but do not store it immediately in the Address Book.

```ruby
ab.new_person(:first_name => "Bob")
=> #<AddressBook::Person:-1: {:first_name=>"Bob"}>
ab.last_name = 'Brown'
ab.save
=> #<AddressBook::Person:9: {:first_name=>"Bob", :last_name=>"Brown"}>
```

Get a list of all people matching one attribute with `.find_all_by_XXX`

```ruby
AddressBook::Person.find_all_by_email('alex@example.com')
=> [#<AddressBook::Person:14: {:first_name=>"Alex", :last_name=>"Rothenberg", ...}>]
```

Get the first person matching one attribute with `.find_by_XXX`

```ruby
AddressBook::Person.find_by_email('alex@example.com')
=> #<AddressBook::Person:14: {:first_name=>"Alex", :last_name=>"Rothenberg", ...}>]
```

Get a list of all people matching several attributes with `.where`

```ruby
AddressBook::Person.where(:email => 'alex@example.com', :first_name => 'Alex')
=> [#<AddressBook::Person:14: {:first_name=>"Alex", :last_name=>"Rothenberg", ...}>]
```

Look for an existing person or get a new one if none is found `find_or_new_by_XXX`

```ruby
AddressBook::Person.find_or_new_by_email('alex@example.com')
=> #<AddressBook::Person:17: {:first_name=>"Alex", :last_name=>"Rothenberg", ...}>]
```

### Update existing Person

```ruby
alex = AddressBook::Person.find_by_email('alex@example.com')
alex.job_title = 'RubyMotion Developer'
alex.save
```

Or to alter all the attributes at once (preserve the record identifier
but change some or all of the values):

```ruby
alex = AddressBook::Person.find_by_email('alex@example.com')
alex.replace({:first_name=>"Alex", :last_name=>"Rider", ...})
alex.save
```

### Contact Groups

```ruby
ab.groups
=> [#<AddressBook::Group:1:Friends: 1 members>, #<AddressBook::Group:2:Work: 0 members>]

g = ab.groups.first
g.members
=> [#<AddressBook::Person:2: {:first_name=>"Daniel", :last_name=>"Higgins", ...}>]
```

### Notifications (\* iOS only \*)

The iOS Address Book does not deliver notifications of changes through
the standard Notification Center. `motion-addressbook` wraps the
framework `ABAddressBookRegisterExternalChangeCallback` call with an
optional handler that converts the update event to an iOS
notification.

```ruby
ab.observe!

proc = Proc.new {|notification| NSLog "Address Book was changed!" }
NSNotificationCenter.defaultCenter.addObserverForName(:addressbook_updated, object:nil, queue:NSOperationQueue.mainQueue, usingBlock:proc)

# Or using BubbleWrap:
App.notification_center.observe :addressbook_updated do |notification|
  NSLog "Address Book was changed!"
end
```

The notification must be explicitly enabled in your application. In
some cases iOS appears to trigger multiple notifications for the same
change event, and if you are doing many changes at once you will
receive a long stream of notifications.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

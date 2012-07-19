# Addressbook for RubyMotion

Classes to make it easier to interact with the iOS AddressBook from a RubyMotion app.

## Installation

Add this line to your application's Gemfile:

    gem 'motion-addressbook'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motion-addressbook

## Usage


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

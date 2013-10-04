module AddressBook
  class AddrBook
    attr_reader :ab

    def initialize
      @ab = ABAddressBook.addressBook
    end
    def people(opts = {})
      if opts[:local]
        people.select {|p| p.local?}
      else
        ab.people.map do |ab_person|
          AddressBook::Person.new(ab_person, :address_book => ab)
        end
      end
    end
    def count
      people.count
    end
    def new_person(attributes)
      Person.new(attributes, :address_book => @ab)
    end
    def create_person(attributes)
      p = Person.new(attributes, :address_book => @ab)
      p.save
      p
    end
    def person(id)
      if ab_person = ab.recordForUniqueId(id)
        Person.new(ab_person, :address_book => ab)
      end
    end
    def changedSince(timestamp)
      people.select {|p| p.modification_date > timestamp}
    end

    # get logged-in user's record
    def me
      if this_user = ab.me
        Person.new(this_user, :address_book => ab)
      end
    end

    def groups
      ab.groups.map do |ab_group|
        AddressBook::Group.new(:ab_group => ab_group, :address_book => @ab)
      end
    end
    def group_count
      groups.count
    end
    def new_group(attributes)
      AddressBook::Group.new(:attributes => attributes, :address_book => @ab)
    end
    def group(id)
      if ab_group = ab.recordForUniqueId(id)
        Group.new(:ab_group => ab_group, :address_book => ab)
      end
    end

    def notify_changes(callback, context)
      App.notification_center.observe KABDatabaseChangedExternallyNotification do |notification|
        callback.call(context)
      end
    end

    def inspect
      "#<#{self.class}:#{"0x%0x" % object_id} #{count} people, #{group_count} groups>"
    end
  end
end

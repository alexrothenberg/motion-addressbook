module AddressBook
  class AddrBook
    attr_reader :ab

    def initialize
      @ab = AddressBook.address_book
    end
    def authorized?
      AddressBook.authorized?
    end
    def people(opts = {})
      if opts[:source]
        ABAddressBookCopyArrayOfAllPeopleInSource(ab, opts[:source].ab_source).map do |ab_person|
          AddressBook::Person.new({}, ab_person, :address_book => ab)
        end
      else
        ABAddressBookCopyArrayOfAllPeople(ab).map do |ab_person|
          AddressBook::Person.new({}, ab_person, :address_book => ab)
        end
      end
    end
    def count
      ABAddressBookGetPersonCount(@ab)
    end
    def new_person(attributes)
      Person.new(attributes, nil, :address_book => @ab)
    end
    def create_person(attributes)
      p = Person.new(attributes, nil, :address_book => @ab)
      p.save
      p
    end
    def person(id)
      (p = ABAddressBookGetPersonWithRecordID(ab, id)) && Person.new(nil, p, :address_book => ab)
    end
    def changedSince(timestamp)
      people.select {|p| p.modification_date > timestamp}
    end

    def group_count
      ABAddressBookGetGroupCount(@ab)
    end

    def groups
      ABAddressBookCopyArrayOfAllGroups(@ab).map do |ab_group|
        AddressBook::Group.new(:ab_group => ab_group, :address_book => @ab)
      end
    end
    def new_group(attributes)
      AddressBook::Group.new(:attributes => attributes, :address_book => @ab)
    end
    def group(id)
      (g = ABAddressBookGetGroupWithRecordID(ab, id)) && Group.new(:ab_group => g, :address_book => @ab)
    end

    def notify_changes(callback, context)
      ABAddressBookRegisterExternalChangeCallback(ab, callback, context)
    end

    def sources
      # ABAddressBookCopyArrayOfAllSources(ab).map {|s| ABRecordCopyValue(s, KABSourceTypeProperty)}
      ABAddressBookCopyArrayOfAllSources(ab).map {|s| Source.new(s)}
    end
  end
end

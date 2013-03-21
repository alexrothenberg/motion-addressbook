module AddressBook
  class AddrBook
    attr_reader :ab

    def initialize
      @ab = AddressBook.address_book
    end
    def people
      ABAddressBookCopyArrayOfAllPeople(ab).map do |ab_person|
        AddressBook::Person.new({}, ab_person, :address_book => ab)
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
  end
end

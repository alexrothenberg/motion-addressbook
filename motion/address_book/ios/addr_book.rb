module AddressBook
  class AddrBook
    attr_reader :ab

    def initialize
      if AddressBook.authorized?
        @ab = AddressBook.address_book
      else
        AddressBook.request_authorization { @ab = AddressBook.address_book }
      end
    end

    def authorized?
      AddressAddressBook.authorized?
    end

    def auth!
      raise "iOS Address Book authorization is required." if @ab.nil?
    end

    def people(opts = {}, &block)
      auth!
      ordered_list = ab_people(opts).map do |ab_person|
        AddressBook::Person.new({}, ab_person, :address_book => ab)
      end
      if block
        ordered_list.sort_by { |p| block.call(p) }
      else
        ordered_list
      end
    end
    def count
      ABAddressBookGetPersonCount(@ab)
    end
    def new_person(attributes)
      auth!
      Person.new(attributes, nil, :address_book => @ab)
    end
    def create_person(attributes)
      p = new_person(attributes)
      p.save
      p
    end
    def person(id)
      auth!
      (p = ABAddressBookGetPersonWithRecordID(ab, id)) && Person.new(nil, p, :address_book => ab)
    end
    def changedSince(timestamp)
      people.select {|p| p.modification_date > timestamp}
    end

    def groups
      auth!
      ABAddressBookCopyArrayOfAllGroups(@ab).map do |ab_group|
        AddressBook::Group.new(:ab_group => ab_group, :address_book => @ab)
      end
    end
    def group_count
      ABAddressBookGetGroupCount(@ab)
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
      ABAddressBookCopyArrayOfAllSources(ab).map {|s| Source.new(s)}
    end

    private

    def ab_people(opts = {})
      ab_source = opts[:source]
      ordering = opts.fetch(:ordering) { ABPersonGetSortOrdering() }

      ab_people = if ab_source
                    ABAddressBookCopyArrayOfAllPeopleInSource(ab, ab_source)
                  else
                    ABAddressBookCopyArrayOfAllPeople(ab)
                  end

      ab_people.sort! { |x, y| ABPersonComparePeopleByName(x, y, ordering)  }
      ab_people
    end
  end
end

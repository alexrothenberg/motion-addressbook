module AddressBook
  class AddrBook
    attr_reader :ab

    def initialize(&block)
      @ab = NullAddrBook
      if authorized?
        activate!
        if block_given?
          yield self
        end
      elsif block
        # asynchronous auth
        AddressBook.request_authorization do |granted|
          if granted
            activate!
            block.call(self)
          else
            block.call(nil)
          end
        end
      else
        # synchronous auth
        if native_ab = AddressBook.address_book
          @ab = LiveAddrBook.new(native_ab)
        end
      end
    end

    def self.instance
      @instance ||= new
    end

    def activate!
      @ab = LiveAddrBook.new(AddressBook.address_book)
    end

    def observe!
      @notifier = Proc.new do |ab_instance, always_nil, context|
        App.notification_center.post :addressbook_updated, self
      end
      ab.register_callback(@notifier)
    end

    def authorized?
      AddressBook.authorized?
    end

    def auth!
      raise SecurityError, "iOS Address Book authorization is required." if @ab.nil?
    end

    def people(opts = {}, &block)
      ordered_list = ab_people(opts).map { |p| Person.new(nil, p, address_book: ab.ab) }
      if block
        ordered_list.sort_by { |p| block.call(p) }
      else
        ordered_list
      end
    end
    def count
      ab.person_count
    end
    def new_person(attributes)
      Person.new(attributes, nil, :address_book => ab.ab)
    end
    def create_person(attributes)
      p = new_person(attributes)
      p.save
      p
    end
    def person(id)
      (p = ab.person_with_id(id)) && Person.new(nil, p, :address_book => ab.ab)
    end
    def changedSince(timestamp)
      people.select {|p| p.modification_date > timestamp}
    end

    def groups
      ab.all_groups.map do |ab_group|
        AddressBook::Group.new(:ab_group => ab_group, :address_book => ab.ab)
      end
    end
    def group_count
      ab.group_count
    end
    def new_group(attributes)
      AddressBook::Group.new(:attributes => attributes, :address_book => ab.ab)
    end
    def group(id)
      (g = ab.group_with_id(id)) && Group.new(:ab_group => g, :address_book => ab.ab)
    end

    def notify_changes(callback, context)
      ab.register_callback(callback, context)
    end

    def sources
      ab.sources.map {|s| Source.new(s)}
    end

    def inspect
      "#<#{self.class}:#{"0x%0x" % object_id} #{ab.status}>"
    end

    def picker(options={}, &after)
      AddressBook::Picker.show options, &after
    end

    def creator(options, &after)
      AddressBook::Creator.show(options.merge(ab: self), &after)
    end

    private

    def ab_people(opts = {})
      ab_source = opts[:source]
      ordering = opts.fetch(:ordering) { ABPersonGetSortOrdering() }

      ab_people = if ab_source
                    ab.all_people_in_source(ab_source)
                  else
                    ab.all_people
                  end

      ab_people.sort! { |x, y| ABPersonComparePeopleByName(x, y, ordering)  }
      ab_people
    end
  end

  class NullAddrBook
    def self.status; "pending"; end
    def self.method_missing(*args)
      raise SecurityError, "iOS Address Book authorization is required."
    end
  end

  class LiveAddrBook
    attr_reader :ab
    def initialize(ab)
      @ab = ab
    end
    def status; "live"; end
    def all_people
      ABAddressBookCopyArrayOfAllPeople(ab)
    end
    def all_people_in_source(source)
      ABAddressBookCopyArrayOfAllPeopleInSource(ab, source)
    end
    def person_with_id(id)
      ABAddressBookGetPersonWithRecordID(ab, id)
    end
    def person_count
      ABAddressBookGetPersonCount(ab)
    end
    def all_groups
      ABAddressBookCopyArrayOfAllGroups(ab)
    end
    def group_count
      ABAddressBookGetGroupCount(ab)
    end
    def group_with_id(id)
      ABAddressBookGetGroupWithRecordID(ab, id)
    end
    def sources
      ABAddressBookCopyArrayOfAllSources(ab)
    end
    def register_callback(callback)
      ABAddressBookRegisterExternalChangeCallback(ab, callback, nil)
    end
  end
end

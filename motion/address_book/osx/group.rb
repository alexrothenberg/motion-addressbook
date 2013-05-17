# Wrapper for OSX ABGroup
#
# * groups are saved to the database immediately upon new()
# * members are added with <<
#
module AddressBook
  class Group
    attr_reader :attributes, :error

    def initialize(opts)
      @address_book = opts[:address_book]
      if opts[:ab_group]
        # import existing
        @ab_group = opts[:ab_group]
        @attributes = nil
      else
        # create new
        @ab_group = nil
        @attributes = opts[:attributes]
      end
    end

    def address_book
      @address_book ||= AddressBook.address_book
    end

    def save
      address_book.addRecord(ab_group)
      address_book.save
      @attributes = nil
      self
    end

    def exists?
      address_book.recordForUniqueId(uid)
    end
    def new_record?
      !exists?
    end
    alias :new? :new_record?

    def delete!
      unless new?
        address_book.removeRecord(ab_group)
        address_book.save
        @ab_group = nil
        self
      end
    end

    def ab_group
      @ab_group || convert_dict_to_ab
    end
    alias :ab_record :ab_group

    def get_field(field)
      ab_group.valueForProperty(field)
    end

    def uid
      get_field(KABUIDProperty)
    end

    def name
      get_field(KABGroupNameProperty)
    end

    def size
      members.count
    end

    def members
      people + subgroups
    end
    def people
      ab_group.members.map do |ab_person|
        AddressBook::Person.new({}, ab_person, :address_book => address_book)
      end
    end
    def subgroups
      ab_group.subgroups.map do |subgroup|
        AddressBook::Group.new(:ab_group => subgroup, :address_book => address_book)
      end
    end

    def <<(person_or_group)
      raise ArgumentError, "Must save member before adding to group" if person_or_group.new?
      ABGroupAddMember(ab_group, person_or_group.ab_record, error)
    end

    def local?
      !ab_group.isReadOnly
    end

    def apple_uuid
      get_field('com.apple.uuid')
    end
    # regular groups have a value in the internal "com.apple.uuid" property
    # groups with nil here appear to include
    # * all-local-contacts source (group name is "card")
    # * Facebook source (group name is "addressbook")
    # I suspect that Exchange and DAV sources will show up here too.
    def special?
      apple_uuid.nil?
    end

    private

    def convert_dict_to_ab
      @ab_group = ABGroup.alloc.initWithAddressBook(address_book)

      # groups only have a single regular attribute (name)
      if v = @attributes[:name]
        ab_group.setValue(v, forProperty:KABGroupNameProperty)
      end

      save

      @ab_group
    end
  end
end

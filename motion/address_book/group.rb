module AddressBook
  class Group
    attr_reader :attributes, :error

    def initialize(opts)
      @address_book = opts[:address_book]
      if opts[:ab_group]
        # import existing
        @ab_group = existing_ab_group
        @attributes = nil
      else
        @ab_group = nil
        @attributes = opts[:attributes]
      end
    end

    def address_book
      @address_book ||= AddressBook.address_book
    end

    def self.create(attributes)
      group = new(attributes)
      group.save
      group
    end

    def save
      ABAddressBookAddRecord(address_book, ab_group, error)
      ABAddressBookSave(address_book, error)
      @attributes = nil
      @new_record = false
      self
    end

    def new?
      uid != KABRecordInvalidID
    end

    def ab_group
      @ab_group || convert_dict_to_ab
    end

    def uid
      @uid ||= (@ab_group && ABRecordGetRecordID(@ab_group))
    end

    def name
      ABRecordCopyValue(ab_group, KABGroupNameProperty)
    end

    def size
      members.count
    end

    def members
      Array(ABGroupCopyArrayOfAllMembers(ab_group)).map do |ab_record|
        case rectype = ABRecordGetRecordType(ab_record)
        when KABPersonType
          AddressBook::Person.new(:ab_person => ab_record)
        when KABGroupType
          AddressBook::Group.new(:ab_group => ab_record)
        else
          warn "Unrecognized record type #{rectype} in AB group #{name}"
          nil
        end
      end
    end

    def <<(person_or_group)
      ABGroupAddMember(ab_group, person_or_group, error)
    end

    private

    def convert_dict_to_ab
      @ab_group = ABGroupCreate()

      # groups only have a single regular attribute (name)
      if v = @attributes[:name]
        ABRecordSetValue(@ab_group, KABGroupNameProperty, v, error)
      end

      Array(@attributes[:members]).each do |person_or_group|
        self << person_or_group
      end

      @ab_group
    end
  end
end

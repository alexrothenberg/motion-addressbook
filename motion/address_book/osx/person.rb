module AddressBook
  class Person
    attr_reader :error
    attr_reader :address_book

    def initialize(target, opts = {})
      @address_book = opts.fetch(:address_book) { AddressBook.address_book }
      if target.respond_to?(:fetch)
        # data for a new Person, to be saved to the Address Book
        @ab_person = nil
        @attributes = target
      else
        # existing Person, to be retrieved from the OSX Address Book
        @ab_person = target
        @attributes = nil
      end
    end

    def save
      address_book.addRecord(ab_person)
      address_book.save
      @attributes = nil # force refresh
      uid
    end

    def attributes
      @attributes || import_ab_person
    end

    def ab_person
      @ab_person ||= initialize_ab_person
    end
    alias :ab_record :ab_person

    def uid
      get_field(KABUIDProperty)
    end

    # this is NOT the same as the uid
    # this may be assigned when iCloud syncing is enabled
    def apple_uuid
      get_field('com.apple.uuid')
    end

    def method_missing(method_name, *args)
      if property = ReverseSingleValuePropertyMap[method_name]
        get_field(property)
      elsif property = ReverseSingleValuePropertyMap[method_name.gsub(/=$/, '').to_sym]
        set_field(property, args.first)
        @attributes = nil
      else
        super
      end
    end

    # def self.method_missing(name, *args)
    #   if attribute_name = all_finder?(name)
    #     find_all_by(attribute_name, args.first)
    #   elsif attribute_name = first_finder?(name)
    #     find_by(attribute_name, args.first)
    #   elsif attribute_name = finder_or_new?(name)
    #     find_or_new_by(attribute_name, args.first)
    #   else
    #     super
    #   end
    # end
    # def self.is_attribute?(attribute_name)
    #   return false if attribute_name.nil?
    #   attribute_map.include?(attribute_name.to_sym) || [:email, :phone_number].include?( attribute_name.to_sym)
    # end

    # def getter?(method_name)
    #   if self.class.is_attribute? method_name
    #     method_name
    #     # true
    #   else
    #     nil
    #   end
    # end
    # def setter?(method_name)
    #   method_name.to_s =~ /^(\w*)=$/
    #   if self.class.is_attribute? $1
    #     $1
    #   else
    #     nil
    #   end
    # end

    def get(attribute_name)
      # label, attribute = attribute_name.split('_')
      # self.send("#{attribute}s").first_for(label)
      attributes[attribute_name.to_sym] ||= get_field(attribute_map[attribute_name])
    end

    def set(attribute_name, value)
      set_field(attribute_map[attribute_name.to_sym], value)
      attributes[attribute_name.to_sym] = value
    end

    def photo_image
      UIImage.alloc.initWithData(photo)
    end

    def photo
      ab_person.imageData
    end

    def photo=(photo_data)
      ab_person.setImageData(photo_data)
    end

    def get_multi_valued(field)
      if mv = get_field(field)
        MultiValued.new(:ab_multi_value => mv)
      else
        []
      end
    end

    def phones
      get_multi_valued(KABPhoneProperty)
    end

    def phone_values
      phones.attributes.map {|r| r[:value]}
    end

    def emails
      get_multi_valued(KABEmailProperty)
    end

    def email_values
      emails.attributes.map {|r| r[:value]}
    end

    def addresses
      get_multi_valued(KABAddressProperty)
    end

    def urls
      get_multi_valued(KABURLsProperty)
    end

    def social_profiles
      get_multi_valued(KABSocialProfileProperty)
    end

    def im_profiles
      get_multi_valued(KABInstantMessageProperty)
    end

    def related_names
      get_multi_valued(KABRelatedNamesProperty)
    end

    def dates
      get_multi_valued(KABDateProperty)
    end

    def email; email_values.first; end
    def phone; phone_values.first; end
    def url; urls.attributes.first[:value]; end
    def address; addresses.attributes.first; end

    # def find_or_new
    #   if new_record?
    #     new_ab_person
    #   else
    #     existing_record
    #   end
    # end

    # has this record already been saved to the address book?
    def exists?
      uid && ABAddressBook.sharedAddressBook.recordForUniqueId(uid)
    end
    def new_record?
      !exists?
    end
    alias :new? :new_record?

    def delete!
      if exists?
        address_book.removeRecord(ab_person)
        address_book.save
        @ab_person = nil
        self
      end
    end

    # not supported on OSX
    # def composite_name
    #   ABRecordCopyCompositeName(ab_person)
    # end

    def person?
      (get_field(KABPersonFlags) & KABShowAsCompany == 0)
    end
    def organization?
      (get_field(KABPersonFlags) & KABShowAsCompany == 1)
    end

    def modification_date
      get_field(KABModificationDateProperty)
    end

    def creation_date
      get_field(KABCreationDateProperty)
    end

    # replace *all* properties of an existing Person with new values
    def replace(new_attributes)
      @attributes = new_attributes
      load_ab_person
    end

    def linked_people
      recs = ab_person.linkedPeople
      recs.delete(ab_person) # LinkedPeople always includes self
      recs.map do |linked_rec|
        Person.new(nil, linked_rec, :address_book => address_book)
      end
    end

    def to_vcard
      ab_person.vCardRepresentation
    end

    def groups
      ab_person.parentGroups.map do |ab_group|
        AddressBook::Group.new(:ab_group => ab_group, :address_book => address_book)
      end
    end

    def local?
      !ab_person.isReadOnly
    end

    def to_s
      "#<#{self.class}:#{uid}: #{attributes}>"
    end
    alias :inspect :to_s

    # private

    SingleValuePropertyMap = {
      KABFirstNameProperty => :first_name,
      KABLastNameProperty => :last_name,
      KABMiddleNameProperty => :middle_name,
      KABTitleProperty => :prefix,
      KABSuffixProperty => :suffix,
      KABNicknameProperty => :nickname,
      KABJobTitleProperty => :job_title,
      KABDepartmentProperty => :department,
      KABOrganizationProperty => :organization,
      KABBirthdayProperty => :birthday,
      KABNoteProperty => :note
    }
    ReverseSingleValuePropertyMap = SingleValuePropertyMap.invert

    MultiValuePropertyMap = {
      KABPhoneProperty => :phones,
      KABEmailProperty => :emails,
      KABAddressProperty => :addresses,
      KABURLsProperty => :urls,
      KABSocialProfileProperty => :social_profiles,
      KABInstantMessageProperty => :im_profiles,
      KABRelatedNamesProperty => :related_names,
      KABOtherDatesProperty => :dates
    }

    # instantiates ABPerson record from attributes
    def initialize_ab_person
      @ab_person = ABPerson.alloc.initWithAddressBook(address_book)
      load_ab_person
      @ab_person
    end

    def load_ab_person
      @attributes ||= {}

      SingleValuePropertyMap.each do |ab_property, attr_key|
        if attributes[attr_key]
          set_field(ab_property, attributes[attr_key])
        else
          remove_field(ab_property)
        end
      end

      if attributes[:is_org]
        set_field(KABPersonFlags, KABShowAsCompany)
      else
        set_field(KABPersonFlags, KABShowAsPerson)
      end

      MultiValuePropertyMap.each do |ab_property, attr_key|
        if attributes[attr_key]
          set_multi_valued(ab_property, attributes[attr_key])
        else
          remove_field(ab_property)
        end
      end

      ab_person
    end

    # populate attributes from existing ABPerson
    def import_ab_person
      @attributes = {}
      @modification_date = nil

      SingleValuePropertyMap.each do |ab_property, attr_key|
        if value = get_field(ab_property)
          @attributes[attr_key] = value
        end
      end

      if organization?
        @attributes[:is_org] = true
      end

      MultiValuePropertyMap.each do |ab_property, attr_key|
        if value = get_multi_valued(ab_property)
          if value.any?
            @attributes[attr_key] = value.attributes
          end
        end
      end

      @attributes
    end

    def set_field(field, value)
      if value
        ab_person.setValue(value, forProperty:field)
      end
    end
    def get_field(field)
      ab_person.valueForProperty(field)
    end
    def remove_field(field)
      ab_person.removeValueForProperty(field)
    end

    def set_multi_valued(field, values)
      values = values.map { |value| ( (value.kind_of?String) ? {:value => value} : value)}
      if values && values.any?
        multi_field = MultiValued.new(:attributes => values)
        set_field(field, multi_field.ab_multi_value)
      end
    end
  end
end

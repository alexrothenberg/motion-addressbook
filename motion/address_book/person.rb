module AddressBook
  class Person
    attr_reader :error, :ab_person

    def initialize(attributes={}, existing_ab_person = nil, opts = {})
      @address_book = opts[:address_book]
      if existing_ab_person.nil?
        @ab_person = nil
        @attributes = attributes
        @new_record = true
      else
        @ab_person = existing_ab_person
        @attributes = nil
        # import_ab_person
        @new_record = false
      end
    end

    def self.all
      ab = AddressBook.address_book
      ab_people = ABAddressBookCopyArrayOfAllPeople(ab)
      return [] if ab_people.nil?

      people = ab_people.map do |ab_person|
        new({}, ab_person, :address_book => ab)
      end
      people.sort! { |a,b| "#{a.first_name} #{a.last_name}" <=> "#{b.first_name} #{b.last_name}" }
      people
    end

    def self.create(attributes)
      person = new(attributes)
      person.save
      person
    end

    def save
      ABAddressBookAddRecord(address_book, ab_person, error)
      ABAddressBookSave(address_book, error)
      # @address_book = nil #force refresh
      @attributes = nil # force refresh
      @new_record = false
      uid
    end

    def attributes
      @attributes || import_ab_person
    end

    def ab_person
      if @ab_person.nil?
        @ab_person = ABPersonCreate()
        load_ab_person
      end
      @ab_person
    end

    def uid
      @uid ||= (@ab_person && ABRecordGetRecordID(@ab_person))
    end

    def self.where(conditions)
      all.select do |person|
        person.meets? conditions
      end
    end

    def meets?(conditions)
      conditions.keys.all? do |attribute|
        case attribute
        when :email
          emails.attributes.map {|rec| rec[:value]}.any? {|v| v == conditions[attribute]}
        else
          send(attribute) == conditions[attribute]
        end
      end
    end

    def self.attribute_map
      {
        :first_name   => KABPersonFirstNameProperty,
        :middle_name   => KABPersonMiddleNameProperty,
        :last_name    => KABPersonLastNameProperty,
        :suffix    => KABPersonSuffixProperty,
        :nickname    => KABPersonNicknameProperty,
        :job_title    => KABPersonJobTitleProperty,
        :department   => KABPersonDepartmentProperty,
        :organization => KABPersonOrganizationProperty,
        :dob    => KABPersonBirthdayProperty,
        :note    => KABPersonNoteProperty
      }
    end
    def attribute_map
      self.class.attribute_map
    end

    def method_missing(name, *args)
      if attribute_name = getter?(name)
        get(attribute_name)
      elsif attribute_name = setter?(name)
        set(attribute_name, args.first)
      else
        super
      end
    end

    def self.method_missing(name, *args)
      if attribute_name = all_finder?(name)
        find_all_by(attribute_name, args.first)
      elsif attribute_name = first_finder?(name)
        find_by(attribute_name, args.first)
      elsif attribute_name = finder_or_new?(name)
        find_or_new_by(attribute_name, args.first)
      else
        super
      end
    end
    def self.is_attribute?(attribute_name)
      return false if attribute_name.nil?
      attribute_map.include?(attribute_name.to_sym) || [:email, :phone_number].include?( attribute_name.to_sym)
    end

    def getter?(method_name)
      if self.class.is_attribute? method_name
        method_name
      else
        nil
      end
    end
    def setter?(method_name)
      method_name.to_s =~ /^(\w*)=$/
      if self.class.is_attribute? $1
        $1
      else
        nil
      end
    end
    def self.all_finder?(method_name)
      method_name.to_s =~ /^find_all_by_(\w*)$/
      if is_attribute? $1
        $1
      else
        nil
      end
    end
    def self.first_finder?(method_name)
      method_name.to_s =~ /^find_by_(\w*)$/
      if is_attribute? $1
        $1
      else
        nil
      end
    end
    def self.finder_or_new?(method_name)
      method_name.to_s =~ /^find_or_new_by_(\w*)$/
      if is_attribute? $1
        $1
      else
        nil
      end
    end

    def get(attribute_name)
      attributes[attribute_name.to_sym] ||= get_field(attribute_map[attribute_name])
    end

    def set(attribute_name, value)
      set_field(attribute_map[attribute_name.to_sym], value)
      attributes[attribute_name.to_sym] = value
    end

    def self.find_by_uid(criteria)
      find_by :uid, criteria
    end

    def self.find_all_by(attribute_name, criteria)
      where({attribute_name.to_sym => criteria})
    end
    def self.find_by(attribute_name, criteria)
      find_all_by(attribute_name, criteria).first
    end
    def self.new_by(attribute_name, criteria)
      case attr_sym = attribute_name.to_sym
      when :email
        new({:emails => [{:value => criteria}]})
      else
        new({attr_sym => criteria})
      end
    end
    def self.find_or_new_by(attribute_name, criteria)
      find_by(attribute_name, criteria) || new_by(attribute_name, criteria)
    end

    def photo
      ABPersonCopyImageData(ab_person)
    end

    def photo=(photo_data)
      ABPersonSetImageData(ab_person, photo_data, error)
    end

    def get_multi_valued(field)
      MultiValued.new(:ab_multi_value => ABRecordCopyValue(ab_person, field))
    end

    def phones
      get_multi_valued(KABPersonPhoneProperty)
    end

    def phones_values
      phones.attributes.map {|r| r[:value]}
    end

    def emails
      get_multi_valued(KABPersonEmailProperty)
    end

    def email_values
      emails.attributes.map {|r| r[:value]}
    end

    def addresses
      get_multi_valued(KABPersonAddressProperty)
    end

    def urls
      get_multi_valued(KABPersonURLProperty)
    end

    def social_profiles
      get_multi_valued(KABPersonSocialProfileProperty)
    end

    def im_profiles
      get_multi_valued(KABPersonInstantMessageProperty)
    end

    def find_or_new
      if new_record?
        new_ab_person
      else
        existing_record
      end
    end

    def new_record?
      !!@new_record
    end
    def exists?
      !new_record?
    end

    def delete!
      unless new_record?
        ABAddressBookRemoveRecord(address_book, ab_person, error)
        ABAddressBookSave(address_book, error)
        @address_book = nil
        @new_record = true
        @ab_person = nil
      end
    end

    def composite_name
      ABRecordCopyCompositeName(ab_person)
    end

    private

    def single_value_property_map
      {
        KABPersonFirstNameProperty => :first_name,
        KABPersonLastNameProperty => :last_name,
        KABPersonMiddleNameProperty => :middle_name,
        KABPersonSuffixProperty => :suffix,
        KABPersonNicknameProperty => :nickname,
        KABPersonJobTitleProperty => :job_title,
        KABPersonDepartmentProperty => :department,
        KABPersonOrganizationProperty => :organization,
        KABPersonBirthdayProperty => :dob,
        KABPersonNoteProperty => :note
      }
    end

    def multi_value_property_map
      {
        KABPersonPhoneProperty => :phones,
        KABPersonEmailProperty => :emails,
        KABPersonAddressProperty => :addresses,
        KABPersonURLProperty => :urls,
        KABPersonSocialProfileProperty => :social_profiles,
        KABPersonInstantMessageProperty => :im_profiles
      }
    end

    # instantiates ABPerson record from attributes
    def load_ab_person
      single_value_property_map.each do |ab_property, attr_key|
        if attributes[attr_key]
          set_field(ab_property, attributes[attr_key])
        end
      end

      if attributes[:is_org]
        set_field(KABPersonKindProperty, KABPersonKindOrganization)
      else
        set_field(KABPersonKindProperty, KABPersonKindPerson)
      end

      multi_value_property_map.each do |ab_property, attr_key|
        if attributes[attr_key]
          set_multi_valued(ab_property, attributes[attr_key])
        end
      end
    end

    def import_ab_person
      @attributes = {}
      single_value_property_map.each do |ab_property, attr_key|
        if value = get_field(ab_property)
          @attributes[attr_key] = value
        end
      end

      if organization?
        @attributes[:is_org] = true
      end

      multi_value_property_map.each do |ab_property, attr_key|
        @attributes[attr_key] = get_multi_valued(ab_property)
      end

      @attributes
    end

    def set_field(field, value)
      if value
        ABRecordSetValue(ab_person, field, value, error)
      end
    end
    def get_field(field)
      ABRecordCopyValue(ab_person, field)
    end

    def set_multi_valued(field, values)
      if values && values.any?
        multi_field = MultiValued.new(:attributes => values)
        ABRecordSetValue(ab_person, field, multi_field.ab_multi_value, nil)
      end
    end

    def person?
      get_field(KABPersonKindProperty) == KABPersonKindPerson
    end
    def organization?
      get_field(KABPersonKindProperty) == KABPersonKindOrganization
    end

    def existing_records
      potential_matches = ABAddressBookCopyPeopleWithName(address_book, attributes[:first_name])
      potential_matches.select do |record|
        multi_field = MultiValue.new ABRecordCopyValue(record, KABPersonEmailProperty)
        multi_field.include? attributes[:email]
      end
    end

    def existing_record
      # what if there are more than one match? email should be unique but ...
      existing_records.first
    end

    def address_book
      @address_book ||= AddressBook.address_book
    end
  end
end

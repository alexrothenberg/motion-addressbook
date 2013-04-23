module AddressBook
  class Person
    attr_reader :error

    def initialize(attributes={}, existing_ab_person = nil, opts = {})
      @address_book = opts[:address_book]
      if existing_ab_person.nil?
        @ab_person = nil
        @attributes = attributes
      else
        @ab_person = existing_ab_person
        @attributes = nil
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
      @attributes = nil # force refresh
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
    alias :ab_record :ab_person

    def uid
      ABRecordGetRecordID(ab_person)
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
        :middle_name  => KABPersonMiddleNameProperty,
        :last_name    => KABPersonLastNameProperty,
        :suffix       => KABPersonSuffixProperty,
        :nickname     => KABPersonNicknameProperty,
        :job_title    => KABPersonJobTitleProperty,
        :department   => KABPersonDepartmentProperty,
        :organization => KABPersonOrganizationProperty,
        :birthday     => KABPersonBirthdayProperty,
        :note         => KABPersonNoteProperty
      }
    end
    def attribute_map
      self.class.attribute_map
    end

    def method_missing(name, *args)
      if attribute_name = getter?(name)
        get(attribute_name)
      # if getter?(name)
      #   get(name)
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
        # true
      else
        nil
        # attribute = method_name.split('_').last
        # if ['email', 'phone'].include?(attribute)
        #   true
        # else
        #   false
        # end
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
      # label, attribute = attribute_name.split('_')
      # self.send("#{attribute}s").first_for(label)
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
      abpd = ABPersonCopyImageData(ab_person)
      UIImage.alloc.initWithData(abpd)
    end

    def photo=(photo_data)
      ABPersonSetImageData(ab_person, photo_data, error)
    end

    def get_multi_valued(field)
      if mv = ABRecordCopyValue(ab_person, field)
        MultiValued.new(:ab_multi_value => mv)
      end
    end

    def phones
      get_multi_valued(KABPersonPhoneProperty)
    end

    def phone_values
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

    def related_names
      get_multi_valued(KABPersonRelatedNamesProperty)
    end

    def dates
      get_multi_valued(KABPersonDateProperty)
    end

    def email; email_values.first; end
    def phone; phone_values.first; end
    def url; urls.attributes.first[:value]; end
    def address; addresses.attributes.first; end

    def find_or_new
      if new_record?
        new_ab_person
      else
        existing_record
      end
    end

    def new_record?
      uid == KABRecordInvalidID
    end
    alias :new? :new_record?
    def exists?
      !new_record?
    end

    def delete!
      unless new_record?
        ABAddressBookRemoveRecord(address_book, ab_person, error)
        ABAddressBookSave(address_book, error)
        @ab_person = nil
        self
      end
    end

    def composite_name
      ABRecordCopyCompositeName(ab_person)
    end

    def person?
      get_field(KABPersonKindProperty) == KABPersonKindPerson
    end
    def organization?
      get_field(KABPersonKindProperty) == KABPersonKindOrganization
    end

    def modification_date
      # workaround for RubyMotion bug: blows up when fetching NSDate properties
      # see http://hipbyte.myjetbrains.com/youtrack/issue/RM-81
      ABHack.getDateProperty(KABPersonModificationDateProperty, from: ab_person)
    end

    def creation_date
      ABHack.getDateProperty(KABPersonCreationDateProperty, from: ab_person)
    end

    # replace *all* properties of an existing Person with new values
    def replace(new_attributes)
      @attributes = new_attributes
      load_ab_person
    end

    def source
      s = ABPersonCopySource(ab_person)
      Source.new(s)
      # fetching KABSourceNameProperty always seems to return NULL
      # ABRecordCopyValue(s, KABSourceTypeProperty)
    end

    def linked_people
      recs = ABPersonCopyArrayOfAllLinkedPeople(ab_person).mutableCopy
      recs.delete(ab_person) # LinkedPeople always includes self
      recs.map do |linked_rec|
        Person.new(nil, linked_rec, :address_book => address_book)
      end
    end

    private

    def self.single_value_property_map
      {
        KABPersonFirstNameProperty => :first_name,
        KABPersonLastNameProperty => :last_name,
        KABPersonMiddleNameProperty => :middle_name,
        KABPersonSuffixProperty => :suffix,
        KABPersonNicknameProperty => :nickname,
        KABPersonJobTitleProperty => :job_title,
        KABPersonDepartmentProperty => :department,
        KABPersonOrganizationProperty => :organization,
        KABPersonBirthdayProperty => :birthday,
        KABPersonNoteProperty => :note
      }
    end

    def self.multi_value_property_map
      {
        KABPersonPhoneProperty => :phones,
        KABPersonEmailProperty => :emails,
        KABPersonAddressProperty => :addresses,
        KABPersonURLProperty => :urls,
        KABPersonSocialProfileProperty => :social_profiles,
        KABPersonInstantMessageProperty => :im_profiles,
        KABPersonRelatedNamesProperty => :related_names,
        KABPersonDateProperty => :dates
      }
    end

    # instantiates ABPerson record from attributes
    def load_ab_person
      @attributes ||= {}

      Person.single_value_property_map.each do |ab_property, attr_key|
        if attributes[attr_key]
          set_field(ab_property, attributes[attr_key])
        else
          remove_field(ab_property)
        end
      end

      if attributes[:is_org]
        set_field(KABPersonKindProperty, KABPersonKindOrganization)
      else
        set_field(KABPersonKindProperty, KABPersonKindPerson)
      end

      Person.multi_value_property_map.each do |ab_property, attr_key|
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

      Person.single_value_property_map.each do |ab_property, attr_key|
        if value = get_field(ab_property)
          @attributes[attr_key] = value
        end
      end

      if organization?
        @attributes[:is_org] = true
      end

      Person.multi_value_property_map.each do |ab_property, attr_key|
        if value = get_multi_valued(ab_property)
          if value.attributes.any?
            @attributes[attr_key] = value.attributes
          end
        end
      end

      @attributes
    end

    def set_field(field, value)
      if value
        ABRecordSetValue(ab_person, field, value, error)
      end
    end
    def get_field(field)
      if field == KABPersonBirthdayProperty
        # special case: RubyMotion blows up on NSDate properties
        # see http://hipbyte.myjetbrains.com/youtrack/issue/RM-81
        ABHack.getDateProperty(field, from: ab_person)
      else
        ABRecordCopyValue(ab_person, field)
      end
    end
    def remove_field(field)
      ABRecordRemoveValue(ab_person, field, nil)
    end

    def set_multi_valued(field, values)
      values = values.map { |value| ( (value.kind_of?String) ? {:value => value} : value)}
      if values && values.any?
        multi_field = MultiValued.new(:attributes => values)
        ABRecordSetValue(ab_person, field, multi_field.ab_multi_value, nil)
      end
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

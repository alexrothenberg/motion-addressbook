module AddressBook
  class Person
    attr_reader :attributes, :error, :ab_person

    def initialize(attributes={}, existing_ab_person = nil)
      @attributes = attributes
      if existing_ab_person.nil?
        @new_record = true
      else
        @ab_person = existing_ab_person
        load_ab_person
        @new_record = false
      end
    end

    def self.all
      people = ABAddressBookCopyArrayOfAllPeople(AddressBook.address_book).map do |ab_person|
        new({}, ab_person)
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
      ABAddressBookSave(address_book, error )
      @address_book = nil #force refresh
      @new_record = false
    end

    def self.where(conditions)
      all.select do |person|
        person.meets? conditions
      end
    end

    def meets?(conditions)
      conditions.keys.all? do |attribute|
        send(attribute) == conditions[attribute]
      end
    end

    def self.attribute_map
      { :first_name   => KABPersonFirstNameProperty,
        :last_name    => KABPersonLastNameProperty,
        :job_title    => KABPersonJobTitleProperty,
        :department   => KABPersonDepartmentProperty,
        :organization => KABPersonOrganizationProperty
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

    def self.find_all_by(attribute_name, criteria)
      where({attribute_name.to_sym => criteria})
    end
    def self.find_by(attribute_name, criteria)
      find_all_by(attribute_name, criteria).first
    end
    def self.find_or_new_by(attribute_name, criteria)
      find_by(attribute_name, criteria) || new({attribute_name.to_sym => criteria})
    end

    def photo
      ABPersonCopyImageData(ab_person)
    end

    def photo=(photo_data)
      ABPersonSetImageData(ab_person, photo_data, error)
    end


    def phone_numbers
      get_multi_field(KABPersonPhoneProperty)
    end

    def phone_number_values
      phone_numbers.values
    end

    def emails
      get_multi_field(KABPersonEmailProperty )
    end

    def email_values
      emails.values
    end

    # UGH - kinda arbitrary way to deal with multiple values.  DO SOMETHING BETTER.
    def email
      @attributes[:email] ||= email_values.first
    end
    def phone_number
      @attributes[:phone_number] ||= phone_number_values.first
    end

    def ab_person
      if @ab_person.nil?
        @ab_person = ABPersonCreate()
        load_ab_person
      end
      @ab_person
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
    def inspect
      # ensure all attributes loaded
      attribute_map.keys.each do |attribute|
        self.send(attribute)
      end

      super
    end

    private

    def load_ab_person
      set_field(KABPersonFirstNameProperty,    attributes[:first_name  ]) unless attributes[:first_name  ].nil?
      set_field(KABPersonLastNameProperty,     attributes[:last_name   ]) unless attributes[:last_name   ].nil?
      set_field(KABPersonJobTitleProperty,     attributes[:job_title   ]) unless attributes[:job_title   ].nil?
      set_field(KABPersonDepartmentProperty,   attributes[:department  ]) unless attributes[:department  ].nil?
      set_field(KABPersonOrganizationProperty, attributes[:organization]) unless attributes[:organization].nil?
      set_multi_field(KABPersonPhoneProperty,  :mobile => attributes[:mobile_phone], :work => attributes[:office_phone])
      set_multi_field(KABPersonEmailProperty,  :work => attributes[:email])
    end

    def set_field(field, value)
      ABRecordSetValue(ab_person, field, value, error)
    end
    def get_field(field)
      ABRecordCopyValue(ab_person, field)
    end

    def set_multi_field(field, values)
      multi_field = MultiValue.new(values, ABRecordCopyValue(ab_person, field))
      ABRecordSetValue(ab_person, field, multi_field.ab_multi_values, error )
    end
    def get_multi_field(field)
      MultiValue.new({}, ABRecordCopyValue(ab_person, field))
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

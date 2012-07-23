module AddressBook
  class Person
    attr_reader :attributes, :error, :ab_person

    def initialize(attributes, ab_person = nil)
      @attributes = attributes
      load_ab_person(ab_person)
    end

    def self.all
      address_book = ABAddressBookCreate()
      ABAddressBookCopyArrayOfAllPeople(address_book).map do |ab_person|
        new({}, ab_person)
      end
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
    end

    def attribute_map
      { :first_name   => KABPersonFirstNameProperty,
        :last_name    => KABPersonLastNameProperty,
        :job_title    => KABPersonJobTitleProperty,
        :department   => KABPersonDepartmentProperty,
        :organization => KABPersonOrganizationProperty
      }
    end

    def method_missing(name, *args)
      name.to_s =~ /^(\w*)(=?)$/
      attribute_name = $1.to_sym unless $1.nil?
      if attribute_map.include? attribute_name
        if $2 == '='
          set_field(attribute_map[attribute_name], args.first)
          attributes[attribute_name] = args.first
        else
          attributes[attribute_name] ||= get_field(attribute_map[attribute_name])
        end
      else
        super
      end
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

    # private

    def load_ab_person(ab_person = nil)
      @ab_person = ab_person || find_or_new
      set_field(KABPersonFirstNameProperty,    attributes[:first_name  ]) unless attributes[:first_name  ].nil?
      set_field(KABPersonLastNameProperty,     attributes[:last_name   ]) unless attributes[:last_name   ].nil?
      set_field(KABPersonJobTitleProperty,     attributes[:job_title   ]) unless attributes[:job_title   ].nil?
      set_field(KABPersonDepartmentProperty,   attributes[:department  ]) unless attributes[:department  ].nil?
      set_field(KABPersonOrganizationProperty, attributes[:organization]) unless attributes[:organization].nil?
      set_multi_field(KABPersonPhoneProperty,  KABPersonPhoneMobileLabel => attributes[:mobile_phone], KABWorkLabel => attributes[:office_phone])
      set_multi_field(KABPersonEmailProperty,  KABWorkLabel => attributes[:email])
    end

    def set_field(field, value)
      ABRecordSetValue(ab_person, field, value, error)
    end
    def get_field(field)
      ABRecordCopyValue(ab_person, field)
    end

    def set_multi_field(field, values)
      multi_field = MultiValue.new(ABRecordCopyValue(ab_person, field))
      multi_field.set_many(values)
      ABRecordSetValue(ab_person, field, multi_field.ab_multi_values, error )
    end
    def get_multi_field(field)
      MultiValue.new(ABRecordCopyValue(ab_person, field))
    end

    def find_or_new
      if new_record?
        ab_person = ABPersonCreate()
        ABAddressBookAddRecord(address_book, ab_person, error )
        ab_person
      else
        existing_record
      end
    end

    def existing_records
      potential_matches = ABAddressBookCopyPeopleWithName(address_book, attributes[:first_name])
      potential_matches.select do |record|
        multi_field = MultiValue.new ABRecordCopyValue(record, KABPersonEmailProperty)
        multi_field.include? attributes[:email]
      end
    end

    def exists?
      !new_record?
    end
    def new_record?
      existing_record.nil?
    end
    def existing_record
      # what if there are more than one match? email should be unique but ...
      existing_records.first
    end

    def address_book
      @address_book ||= ABAddressBookCreate()
    end

    def inspect
      # ensure all attributes loaded
      attribute_map.keys.each do |attribute|
        self.send(attribute)
      end

      super
    end

    # def define_some_constants
    #   [KABWorkLabel, KABOtherLabel, KABHomeLabel]
    # end
  end
end
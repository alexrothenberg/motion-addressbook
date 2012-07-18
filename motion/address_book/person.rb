module AddressBook
  class Person
    attr_reader :attributes, :error, :ab_person

    def initialize(attributes)
      @attributes = attributes
      load_ab_person
    end

    def save
      ABAddressBookSave(address_book, error )
      @address_book = nil #force refresh
    end
    
    # private

    def load_ab_person
      @ab_person = find_or_new
      set_field(KABPersonFirstNameProperty,    attributes[:first_name  ])
      set_field(KABPersonLastNameProperty,     attributes[:last_name   ])
      set_field(KABPersonJobTitleProperty,     attributes[:title       ])
      set_field(KABPersonDepartmentProperty,   attributes[:department  ])
      set_field(KABPersonOrganizationProperty, attributes[:organization])
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
      multi_field = MultiValue.new(ABRecordCopyValue(ab_person, field))
      multi_field.values
    end

    def find_or_new
      if exists?
        existing_record
      else
        ab_person = ABPersonCreate()
        ABAddressBookAddRecord(address_book, ab_person, error )
        ab_person
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
      existing_record
    end
    def existing_record
      # what if there are more than one match? email should be unique but ...
      existing_records.first
    end

    def address_book
      @address_book ||= ABAddressBookCreate()
    end

    def define_some_constants
      [KABWorkLabel, KABOtherLabel, KABHomeLabel]
    end
  end
end
module AddressBook
  class MultiValued
    def initialize(opts)
      unless opts.one?
        raise ArgumentError, "MultiValued requires :attributes *or* :ab_multi_value argument"
      end

      if opts[:ab_multi_value]
        # @ab_multi_value = ABMultiValueCreateMutableCopy(opts[:ab_multi_value])
        @ab_multi_value = opts[:ab_multi_value]
      else
        @attributes = opts[:attributes]
      end
    end

    def count
      ABMultiValueGetCount(ab_multi_value)
    end
    alias :size :count

    def attributes
      @attributes ||= convert_multi_value_into_dictionary
    end

    def convert_multi_value_into_dictionary
      count.times.map do |i|
        label = ABMultiValueCopyLabelAtIndex(@ab_multi_value, i)
        label_val = ABAddressBookCopyLocalizedLabel(label)
        data = ab_record_to_dict(ABMultiValueCopyValueAtIndex(@ab_multi_value, i))
        data.merge(:label => label_val)
      end
    end

    def ab_multi_value
      @ab_multi_value ||= convert_dictionary_into_multi_value
    end

    def convert_dictionary_into_multi_value
      if @attributes.find {|rec| rec[:value]}
        mv = ABMultiValueCreateMutable(KABMultiStringPropertyType)
        @attributes.each do |rec|
          ABMultiValueAddValueAndLabel(mv, rec[:value], rec[:label], nil)
        end
        mv
      else
        mv = ABMultiValueCreateMutable(KABMultiDictionaryPropertyType)
        @attributes.each do |rec|
          if value = dict_to_ab_record(rec)
            ABMultiValueAddValueAndLabel(mv, value, rec[:label], nil)
          end
        end
        mv
      end
    end

    # these are for mapping fields in a kABMultiDictionaryPropertyType record
    # to keys in a standard hash (NSDictionary)
    PropertyMap = {
      KABPersonAddressStreetKey => :street,
      KABPersonAddressCityKey => :city,
      KABPersonAddressStateKey => :state,
      KABPersonAddressZIPKey => :postalcode,
      KABPersonAddressCountryKey => :country,
      KABPersonAddressCountryCodeKey => :country_code,

      KABPersonSocialProfileURLKey => :url,
      KABPersonSocialProfileServiceKey => :service,
      KABPersonSocialProfileUsernameKey => :username,
      KABPersonSocialProfileUserIdentifierKey => :userid,

      # these keys are identical to the SocialProfile keys above
      KABPersonInstantMessageServiceKey => :service,
      KABPersonInstantMessageUsernameKey => :username
    }

    def dict_to_ab_record(h)
      h = PropertyMap.each_with_object({}) do |(ab_key, attr_key), ab_record|
        ab_record[ab_key] = h[attr_key] if h[attr_key]
      end
      h.any? ? h : nil
    end

    def ab_record_to_dict(ab_record)
      case ab_record
      when String
        {:value => ab_record}
      else
        PropertyMap.each_with_object({}) do |(ab_key, attr_key), dict|
          dict[attr_key] = ab_record[ab_key] if ab_record[ab_key]
        end
      end
    end

    def all
      ABMultiValueCopyArrayOfAllValues(ab_multi_value)
    end

    def <<(rec)
      case ABMultiValueGetPropertyType(ab_multi_value)
      when KABMultiStringPropertyType
        ABMultiValueAddValueAndLabel(ab_multi_value, rec[:value], rec[:label], nil)
      when KABInvalidPropertyType
        warn "Owie!"
      else
        ABMultiValueAddValueAndLabel(ab_multi_value, dict_to_ab_record(rec), rec[:label], nil)
      end

      @attributes = convert_multi_value_into_dictionary
    end
  end
end

module AddressBook
  class MultiValued
    def initialize(opts)
      unless opts.one?
        raise ArgumentError, "MultiValued requires attributes *or* ab_multi_value: #{opts}"
      end

      if opts[:ab_multi_value]
        @ab_multi_value = ABMultiValueCreateMutableCopy(opts[:ab_multi_value])
      else
        @attributes = opts[:attributes]
      end
    end

    def attributes
      @attributes ||= convert_multi_value_into_dictionary
    end

    def convert_multi_value_into_dictionary
      count.times.map do |i|
        label = ABMultiValueCopyLabelAtIndex(@ab_multi_value, i)
        label_val = ABAddressBookCopyLocalizedLabel(label)
        data = ab_record_to_hash(ABMultiValueCopyValueAtIndex(@ab_multi_value, i))
        data.merge(:label => label_val)
      end
    end

    def ab_multi_value
      @ab_multi_value ||= convert_dictionary_into_multi_value
    end

    def convert_dictionary_into_multi_value
      mv = ABMultiValueCreateMutable(KABMultiDictionaryPropertyType)
      @attributes.each do |rec|
        ABMultiValueAddValueAndLabel(mv, hash_to_ab_record(rec), rec[:label], nil)
      end
      mv
    end

    @@attribute_map = {
      KABPersonAddressStreetKey => :street,
      KABPersonAddressCityKey => :city,
      KABPersonAddressStateKey => :state,
      KABPersonAddressZIPKey => :postalcode,
      KABPersonAddressCountryKey => :country,

      KABPersonSocialProfileURLKey => :url,
      KABPersonSocialProfileServiceKey => :service,
      KABPersonSocialProfileUsernameKey => :username
    }

    def hash_to_ab_record(h)
      @@attribute_map.each_with_object({}) do |(ab_key, attr_key), ab_record|
        ab_record[ab_key] = h[attr_key] if h[attr_key]
      end
    end

    def ab_record_to_hash(ab_record)
      @@attribute_map.each_with_object({}) do |(ab_key, attr_key), hash|
        hash[attr_key] = ab_record[ab_key] if ab_record[ab_key]
      end
    end

    def count
      ABMultiValueGetCount(ab_multi_value)
    end
  end
end

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
        data = from_address(ABMultiValueCopyValueAtIndex(@ab_multi_value, i))
        data.merge(:label => label_val)
      end
    end

    def ab_multi_value
      @ab_multi_value ||= convert_dictionary_into_multi_value
    end

    def convert_dictionary_into_multi_value
      mv = ABMultiValueCreateMutable(KABMultiDictionaryPropertyType)
      @attributes.each do |rec|
        ABMultiValueAddValueAndLabel(mv, rec_to_ab_address(rec), rec[:label], nil)
      end
      mv
    end

    # must filter out any nil values
    # runtime will crash if it attempts to store nils to the database
    def rec_to_ab_address(h)
      {
        KABPersonAddressStreetKey => h[:street],
        KABPersonAddressCityKey => h[:city],
        KABPersonAddressStateKey => h[:state],
        KABPersonAddressZIPKey => h[:postalcode],
        KABPersonAddressCountryKey => h[:country]
      }.reject {|k,v| v.nil?}
    end

    def from_address(h)
      {
        :street => h[KABPersonAddressStreetKey],
        :city => h[KABPersonAddressCityKey],
        :state => h[KABPersonAddressStateKey],
        :postalcode => h[KABPersonAddressZIPKey],
        :country => h[KABPersonAddressCountryKey]
      }.reject {|k,v| v.nil?}
    end

    def count
      ABMultiValueGetCount(ab_multi_value)
    end
  end
end

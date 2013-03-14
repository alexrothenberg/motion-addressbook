module AddressBook
  class MultiValued
    attr_reader :attributes, :ab_multi_values

    def initialize(inbound=nil, existing_ab_multi_values=nil)
      if existing_ab_multi_values
        @ab_multi_values = ABMultiValueCreateMutableCopy(existing_ab_multi_values)
        convert_multivalue
      else
        @attributes = inbound
        @ab_multi_values = import_into_multi_value
      end
    end

    def import_into_multi_value
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

    def method_missing(name, *args)
      if attribute_name = getter?(name)
        get(attribute_name)
      elsif attribute_name = setter?(name)
        set(attribute_name, args.first)
      else
        super
      end
    end

    def count
      ABMultiValueGetCount(ab_multi_values)
    end

    def convert_multivalue
      @attributes = count.times.map do |i|
        label = ABMultiValueCopyLabelAtIndex(ab_multi_values, i)
        label_val = ABAddressBookCopyLocalizedLabel(label)
        data = from_address(ABMultiValueCopyValueAtIndex(ab_multi_values, i))
        data.merge(:label => label_val)
      end
    end
  end
end

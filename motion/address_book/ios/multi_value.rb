module AddressBook
  class MultiValue
    attr_reader :attributes, :ab_multi_values

    def self.attribute_map
      { :mobile   => KABPersonPhoneMobileLabel ,
        :iphone   => KABPersonPhoneIPhoneLabel ,
        :main     => KABPersonPhoneMainLabel   ,
        :home_fax => KABPersonPhoneHomeFAXLabel,
        :work_fax => KABPersonPhoneWorkFAXLabel,
        :pager    => KABPersonPhonePagerLabel  ,
        :work     => KABWorkLabel              ,
        :home     => KABHomeLabel              ,
        :other    => KABOtherLabel
      }
    end
    def attribute_map
      self.class.attribute_map
    end

    def alex
      ABMultiValueGetIdentifierAtIndex @ab_multi_values, 0
    end

    def initialize(attributes={}, existing_ab_multi_values=nil)
      @attributes = {}
      if existing_ab_multi_values
        @ab_multi_values = ABMultiValueCreateMutableCopy(existing_ab_multi_values)
        load_attributes_from_ab
      else
        @ab_multi_values = ABMultiValueCreateMutable(KABMultiStringPropertyType)
      end
      attributes.each do |attribute, value|
        send("#{attribute}=", value)
      end
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

    def get(attribute_name)
      attributes[attribute_name.to_sym] ||= get_field(attribute_map[attribute_name])
    end

    def set(attribute_name, value)
      set_field(attribute_map[attribute_name.to_sym], value)
      attributes[attribute_name.to_sym] = value
    end

    def set_field(ab_label, value)
      if blank?(ab_label)
        ABMultiValueAddValueAndLabel(@ab_multi_values, value, ab_label, nil) unless value.nil?
      else
        ABMultiValueReplaceValueAtIndex(@ab_multi_values, value, 0)
      end
    end

    def get_field(ab_label)
      puts
      puts [__FILE__, __LINE__, ab_label].inspect
      index = ABMultiValueGetIndexForIdentifier(@ab_multi_values, ab_label)
      puts [__FILE__, __LINE__, index].inspect
      ABMultiValueCopyValueAtIndex(@ab_multi_values, index)
    end

    def values
      attributes.values
    end

    def include? value
      return false if values.nil?
      values.include? value
    end

    def size
      ABMultiValueGetCount(@ab_multi_values)
    end

    def load_attributes_from_ab
      (0...size).to_a.each do |i|
        label = ABMultiValueCopyLabelAtIndex(@ab_multi_values, i)
        @attributes[attribute_map.invert[label]] = ABMultiValueCopyValueAtIndex(@ab_multi_values, i)
      end
    end

    private
    def blank?(ab_label)
      attributes[ab_label].nil?
    end

  end
end

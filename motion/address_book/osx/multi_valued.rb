module AddressBook
  class MultiValued
    attr_reader :mv_type

    def initialize(opts)
      unless opts.one?
        raise ArgumentError, "MultiValued requires :attributes *or* :ab_multi_value argument"
      end

      if opts[:ab_multi_value]
        @ab_multi_value = opts[:ab_multi_value] #ABMultiValueCreateMutableCopy(opts[:ab_multi_value])
      else
        @attributes = opts[:attributes]
        raise ArgumentError, "Empty multi-value objects are not allowed" if @attributes.empty?
      end
    end

    def count
      ab_multi_value.count
    end
    alias :size :count

    def attributes
      @attributes ||= convert_multi_value_into_dictionary
    end

    def convert_multi_value_into_dictionary
      count.times.map do |i|
        data = ab_record_to_dict(i)
        label = @ab_multi_value.labelAtIndex(i)
        if label != ''
          label_val = ABPerson.ABCopyLocalizedPropertyOrLabel(label)
          data[:label] = label_val
        end
        data
      end
    end

    def ab_multi_value
      @ab_multi_value ||= convert_dictionary_into_multi_value
    end

    def localized_label(str)
      LabelMap[str] || str
    end

    def convert_dictionary_into_multi_value
      @mv_type = multi_value_property_type
      mv = ABMutableMultiValue.new

      case mv_type
      when KABMultiStringProperty
        @attributes.each do |rec|
          mv.addValue(rec[:value], withLabel: localized_label(rec[:label]))
        end
      when KABMultiDateProperty
        @attributes.each do |rec|
          mv.addValue(rec[:date], withLabel: localized_label(rec[:label]))
        end
      else # KABMultiDictionaryProperty
        @attributes.each do |rec|
          if value = dict_to_ab_record(rec)
            mv.addValue(value, withLabel: localized_label(rec[:label]))
          end
        end
      end

      mv
    end

    def multi_value_property_type
      if @ab_multi_value
        @ab_multi_value.propertyType
      else
        if attributes.find {|rec| rec[:value]}
          KABMultiStringProperty
        elsif attributes.find {|rec| rec[:date]}
          KABMultiDateProperty
        else
          KABMultiDictionaryProperty
        end
      end
    end

    # these are for mapping fields in a kABMultiDictionaryPropertyType record
    # to keys in a standard hash (NSDictionary)
    PropertyMap = {
      KABAddressStreetKey => :street,
      KABAddressCityKey => :city,
      KABAddressStateKey => :state,
      KABAddressZIPKey => :postalcode,
      KABAddressCountryKey => :country,
      KABAddressCountryCodeKey => :country_code,

      KABSocialProfileURLKey => :url,
      KABSocialProfileServiceKey => :service,
      KABSocialProfileUsernameKey => :username,
      KABSocialProfileUserIdentifierKey => :userid,

      # these keys are identical to the SocialProfile keys above
      KABInstantMessageServiceKey => :service,
      KABInstantMessageUsernameKey => :username
    }

    LabelMap = {
      "mobile"   => KABPhoneMobileLabel ,
      "iphone"   => KABPhoneiPhoneLabel ,
      "main"     => KABPhoneMainLabel   ,
      "home_fax" => KABPhoneHomeFAXLabel,
      "work_fax" => KABPhoneWorkFAXLabel,
      "pager"    => KABPhonePagerLabel  ,
      "work"     => KABWorkLabel        ,
      "home"     => KABHomeLabel        ,
      "other"    => KABOtherLabel       ,
      "home page"=> KABHomePageLabel,
      "anniversary"=> KABAnniversaryLabel
    }

    def dict_to_ab_record(h)
      h = PropertyMap.each_with_object({}) do |(ab_key, attr_key), ab_record|
        ab_record[ab_key] = h[attr_key] if h[attr_key]
      end
      h.any? ? h : nil
    end

    def ab_record_to_dict(i)
      case multi_value_property_type
      when KABMultiStringProperty
        {:value => @ab_multi_value.valueAtIndex(i)}
      when KABMultiDateProperty
        {:date => @ab_multi_value.valueAtIndex(i)}
      when KABMultiDictionaryProperty
        ab_record = @ab_multi_value.valueAtIndex(i)
        PropertyMap.each_with_object({}) do |(ab_key, attr_key), dict|
          dict[attr_key] = ab_record[ab_key] if ab_record[ab_key]
        end
      else
        raise TypeError, "Unknown MultiValue property type #{multi_value_property_type}"
      end
    end

    def <<(rec)
      case multi_value_property_type
      when KABMultiStringProperty
        ABMultiValueAddValueAndLabel(ab_multi_value, rec[:value], localized_label(rec[:label]), nil)
      when KABMultiDateTimeProperty
        ABMultiValueAddValueAndLabel(ab_multi_value, rec[:date], localized_label(rec[:label]), nil)
      when KABMultiDictionaryProperty
        ABMultiValueAddValueAndLabel(ab_multi_value, dict_to_ab_record(rec), localized_label(rec[:label]), nil)
      else
        raise TypeError, "Unknown MultiValue property type #{multi_value_property_type}"
      end

      @attributes = convert_multi_value_into_dictionary
    end

    def first_for(label)
      if rec = attributes.find {|r| r[:label] == label.to_s}
        rec[:value] ? rec[:value] : rec
      end
    end
  end
end

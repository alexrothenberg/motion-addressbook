module AddressBook
  class MultiValued
    attr_reader :mv_type

    def initialize(opts)
      unless opts.one?
        raise ArgumentError, "MultiValued requires :attributes *or* :ab_multi_value argument"
      end

      if opts[:ab_multi_value]
        @ab_multi_value = ABMultiValueCreateMutableCopy(opts[:ab_multi_value])
      else
        @attributes = opts[:attributes]
        raise ArgumentError, "Empty multi-value objects are not allowed" if @attributes.empty?
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
        data = ab_record_to_dict(i)
        data.merge(:label => label_val)
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
      mv = ABMultiValueCreateMutable(mv_type)

      case mv_type
      when KABMultiStringPropertyType
        @attributes.each do |rec|
          ABMultiValueAddValueAndLabel(mv, rec[:value], localized_label(rec[:label]), nil)
        end
      when KABMultiDateTimePropertyType
        @attributes.each do |rec|
          ABMultiValueAddValueAndLabel(mv, rec[:date], localized_label(rec[:label]), nil)
        end
      else # KABMultiDictionaryPropertyType
        @attributes.each do |rec|
          if value = dict_to_ab_record(rec)
            ABMultiValueAddValueAndLabel(mv, value, localized_label(rec[:label]), nil)
          end
        end
      end

      mv
    end

    def multi_value_property_type
      if @ab_multi_value
        ABMultiValueGetPropertyType(@ab_multi_value)
      else
        if attributes.find {|rec| rec[:value]}
          KABMultiStringPropertyType
        elsif attributes.find {|rec| rec[:date]}
          KABMultiDateTimePropertyType
        else
          KABMultiDictionaryPropertyType
        end
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

    LabelMap = {
      "mobile"   => KABPersonPhoneMobileLabel ,
      "iphone"   => KABPersonPhoneIPhoneLabel ,
      "main"     => KABPersonPhoneMainLabel   ,
      "home_fax" => KABPersonPhoneHomeFAXLabel,
      "work_fax" => KABPersonPhoneWorkFAXLabel,
      "pager"    => KABPersonPhonePagerLabel  ,
      "work"     => KABWorkLabel              ,
      "home"     => KABHomeLabel              ,
      "other"    => KABOtherLabel             ,
      "home page"=> KABPersonHomePageLabel,
      "anniversary"=> KABPersonAnniversaryLabel
    }

    def dict_to_ab_record(h)
      h = PropertyMap.each_with_object({}) do |(ab_key, attr_key), ab_record|
        ab_record[ab_key] = h[attr_key] if h[attr_key]
      end
      h.any? ? h : nil
    end

    def ab_record_to_dict(i)
      case multi_value_property_type
      when KABDateTimePropertyType
        {:date => ABMultiValueCopyValueAtIndex(@ab_multi_value, i)}
      when KABStringPropertyType
        {:value => ABMultiValueCopyValueAtIndex(@ab_multi_value, i)}
      when KABDictionaryPropertyType
        ab_record = ABMultiValueCopyValueAtIndex(@ab_multi_value, i)
        PropertyMap.each_with_object({}) do |(ab_key, attr_key), dict|
          dict[attr_key] = ab_record[ab_key] if ab_record[ab_key]
        end
      else
        raise TypeError, "Unknown MultiValue property type"
      end
    end

    def <<(rec)
      case multi_value_property_type
      when KABMultiStringPropertyType
        ABMultiValueAddValueAndLabel(ab_multi_value, rec[:value], localized_label(rec[:label]), nil)
      when KABMultiDateTimePropertyType
        ABMultiValueAddValueAndLabel(ab_multi_value, rec[:date], localized_label(rec[:label]), nil)
      when KABMultiDictionaryPropertyType
        ABMultiValueAddValueAndLabel(ab_multi_value, dict_to_ab_record(rec), localized_label(rec[:label]), nil)
      else
        raise TypeError, "Unknown MultiValue property type"
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

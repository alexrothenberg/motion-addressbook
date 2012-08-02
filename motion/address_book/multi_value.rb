module AddressBook
  class MultiValue
    attr_reader :multivalueIdentifier, :ab_multi_values

    def initialize(ab_multi_values=nil)
      @ab_multi_values = ab_multi_values ? ABMultiValueCreateMutableCopy(ab_multi_values) : ABMultiValueCreateMutable(KABMultiStringPropertyType)
      # @ab_multi_values = ABMultiValueCreateMutable(KABMultiStringPropertyType)
    end

    def set(ab_label, value)
      return if values.include? value  #temp because blank? not working
      if blank?(ab_label)
        ABMultiValueAddValueAndLabel(@ab_multi_values, value, ab_label, multivalueIdentifier) unless value.nil?
      else
        # untested!!!
        ABMultiValueReplaceValueAtIndex(@ab_multi_values, value, index_for(ab_label))
      end
    end

    def set_many(new_values)
      new_values.each do |ab_label, value|
        set(ab_label, value)
      end
    end

    def values
      ABMultiValueCopyArrayOfAllValues(@ab_multi_values) || []
    end

    def include? value
      return false if values.nil?
      values.include? value
    end

    private
    def blank?(ab_label)
      index_for(ab_label) == -1
    end

    def index_for(ab_label)
      return -1 # Keep getting this error :(  <ArgumentError: invalid value for Integer: "_$!<Work>!$_">
      # ABMultiValueGetIndexForIdentifier(@ab_multi_values, ab_label)
    end

  end
end
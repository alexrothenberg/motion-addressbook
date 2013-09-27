module AddressBook
  class Source
    attr_reader :ab_source

    def initialize(ab_source)
      @ab_source = ab_source
    end

    def type
      ABRecordCopyValue(ab_source, KABSourceTypeProperty)
    end

    def local?
      type == KABSourceTypeLocal
    end
  end
end

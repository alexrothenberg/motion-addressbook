describe AddressBook::MultiValued do
  describe 'properties on a new multivalued' do
    describe 'initializing with values' do
      before do
        @attributes = [
          {
            :label => 'home',
            :street => '123 Boring St',
            :city => 'Snoozeville',
            :state => "CA"
          }, {
            :label => 'work',
            :street => '99 Exciting Ave, Suite #200',
            :city => 'Las Vegas',
            :state => "NV"
          }
        ]
        @mv = AddressBook::MultiValued.new(:attributes => @attributes)
      end

      it 'should count the records' do
        @mv.count.should.equal 2
      end

      it 'should store the initial data correctly' do
        @mv.attributes.should.equal @attributes
      end

      it 'should have correct internal representation' do
        internal = @mv.ab_multi_value
        ABMultiValueGetCount(internal).should.equal 2
        ABMultiValueCopyLabelAtIndex(internal, 0).should.equal "home"
        ABMultiValueCopyLabelAtIndex(internal, 1).should.equal "work"
        ABMultiValueCopyValueAtIndex(internal, 0).keys.count.should.equal 3
        ABMultiValueCopyValueAtIndex(internal, 1).keys.count.should.equal 3
      end
    end
  end
end

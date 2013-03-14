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
        @mv = AddressBook::MultiValued.new @attributes
      end

      it 'should count the records' do
        @mv.count.should.equal 2
      end

      it 'should store the initial data correctly' do
        @mv.attributes.should.equal @attributes
      end
    end
  end
end

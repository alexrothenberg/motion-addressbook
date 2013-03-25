describe AddressBook::MultiValued do
  describe 'a string multi-value' do
    before do
      @attributes = [
        {
          :label => 'home page',
          :value => "http://www.mysite.com/"
        }, {
          :label => 'work',
          :value => 'http://dept.bigco.com/'
        }, {
          :label => 'school',
          :value => 'http://state.edu/college'
        }
      ]
      @mv = AddressBook::MultiValued.new(:attributes => @attributes)
    end

    it 'should be countable' do
      @mv.count.should.equal 3
    end

    it 'should be reversible' do
      abmv = @mv.ab_multi_value
      mv2 = AddressBook::MultiValued.new(:ab_multi_value => abmv)
      mv2.attributes.should.equal @attributes
    end
  end

  describe 'a dictionary multi-value' do
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
      @mv.size.should.equal 2
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

  describe 'a broken multi-value' do
    before do
      @attributes = [{:label => 'work', :value => nil}]
      @mv = AddressBook::MultiValued.new(:attributes => @attributes)
    end

    it 'should ignore the missing entry' do
      @mv.size.should.equal 0
    end
  end
end

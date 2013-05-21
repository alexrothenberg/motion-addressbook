describe AddressBook::MultiValued do
  describe 'a new multi-value' do
    it 'should convert to localized labels' do
      AddressBook::MultiValued::LabelMap.size.should.equal 11
      AddressBook::MultiValued::LabelMap.each do |label, localized|
        mv = AddressBook::MultiValued.new(:attributes => [{:label => label, :value => 'test'}])
        ABMultiValueCopyLabelAtIndex(mv.ab_multi_value, 0).should.equal localized
      end
    end

    it "should not allow empty input" do
      ->{AddressBook::MultiValued.new(:attributes => [])}.should.raise ArgumentError
    end
  end

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

    describe 'after appending' do
      before do
        @mv << {:label => 'work', :value => 'another string'}
      end

      it "should have new values" do
        @mv.count.should.equal 4
      end
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
      ABMultiValueCopyLabelAtIndex(internal, 0).should.equal KABHomeLabel
      ABMultiValueCopyLabelAtIndex(internal, 1).should.equal KABWorkLabel
      ABMultiValueCopyValueAtIndex(internal, 0).keys.count.should.equal 3
      ABMultiValueCopyValueAtIndex(internal, 1).keys.count.should.equal 3
    end

    describe 'after appending' do
      before do
        @mv << {:label => 'summer', :city => 'Key West', :state => 'FL'}
      end

      it "should have new values" do
        @mv.count.should.equal 3
      end
    end
  end

  describe 'a date multi-value' do
    before do
      @attributes = [
        {
          :label => 'birthday',
          :date => NSDate.dateWithNaturalLanguageString('April 5, 1962')
        }, {
          :label => 'anniversary',
          :date => NSDate.dateWithNaturalLanguageString('September 22, 1994')
        }, {
          :label => 'death',
          :date => NSDate.dateWithNaturalLanguageString('December 1, 2008')
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
      # 3.should.equal 3
    end

    it 'should not explode' do
      abmv = @mv.ab_multi_value
      mv2 = AddressBook::MultiValued.new(:ab_multi_value => abmv)
      dt = mv2.attributes[1][:date]
      t = NSDate.dateWithNaturalLanguageString('September 22, 1994')
      dt.should.equal t
      dt.should.equal t
      dt.should.equal t
    end

    describe 'after appending' do
      before do
        @mv << {:label => 'graduation', :date => NSDate.dateWithNaturalLanguageString('June 1, 1983')}
      end

      it "should have new values" do
        @mv.count.should.equal 4
      end
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

  describe 'a date multi-value' do
    before do
      @attributes = [{:label => 'anniversary', :date => Time.now}]
      @mv = AddressBook::MultiValued.new(:attributes => @attributes)
    end

    it 'should round-trip input' do
      @mv.attributes.should.equal @attributes
    end
  end
end

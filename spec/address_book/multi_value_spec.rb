describe AddressBook::MultiValue do
  describe 'new field' do
    before do
      @multi_value = AddressBook::MultiValue.new
    end

    describe 'setting one value' do
      before { @multi_value.set(KABWorkLabel, 'alex@work.com') }
      it 'gives access to the values' do
        @multi_value.values.should == ['alex@work.com']
      end
      it 'should know if the value exists' do
        @multi_value.include?('alex@work.com').should.be.true 
      end

      it 'should know if the value exists' do
        @multi_value.include?('not@there.com').should.be.false 
      end
    end
    describe 'setting many values' do
      before { @multi_value.set_many(KABWorkLabel => 'alex@work.com', KABHomeLabel => 'alex@home.com') }
      it 'gives access to the values' do
        @multi_value.values.should == ['alex@work.com', 'alex@home.com']
      end
      it 'should know both values exist' do
        @multi_value.include?('alex@work.com').should.be.true 
        @multi_value.include?('alex@home.com').should.be.true 
      end

      it 'should know if the value exists' do
        @multi_value.include?('not@there.com').should.be.false 
      end
    end
  end

  describe 'existing field' do
    before do
      old_multi_value = AddressBook::MultiValue.new
      old_multi_value.set(KABWorkLabel, 'alex@work.com')
      
      @multi_value = AddressBook::MultiValue.new old_multi_value.ab_multi_values
    end
    
    it 'should have the value' do
      @multi_value.values.should == ['alex@work.com']
    end
    
    it 'should be able to update the value' do
      @multi_value.set(KABWorkLabel, 'alex@new_work.com')
      puts '******PENDING******  Waiting for RubyMotion ABMultiValueGetIndexForIdentifier fix'
      @multi_value.values.should == ['alex@work.com', 'alex@new_work.com'] # ['alex@new_work.com']
    end

    it 'should ignore when updating an existing value to the same value' do
      @multi_value.set(KABWorkLabel, 'alex@work.com')
      @multi_value.values.should == ['alex@work.com']
    end

    it 'should be able to add an additional value' do
      @multi_value.set(KABHomeLabel, 'alex@home.com')
      @multi_value.values.should == ['alex@work.com', 'alex@home.com']
    end

  end
  
end

describe AddressBook::MultiValue do
  describe 'properties on a new multivalue' do
    describe 'initializing with values' do
      before do
        @attributes = { :mobile   => '123-456-7890',   :iphone   => '222-333-4444',   :main  => '555-1212',
                        :home_fax => '1-617-555-8000', :work_fax => '1-212-555-0000', :pager => '99-9999-9999',
                        :work     => 'alex@work.com',  :home     => 'alex@home.com',  :other => 'alex@other.com'}
        @multi_value = AddressBook::MultiValue.new @attributes
      end

      it 'should be able to get each of the single value fields' do
        @multi_value.mobile.should.equal   @attributes[:mobile  ]
        @multi_value.iphone.should.equal   @attributes[:iphone  ]
        @multi_value.main.should.equal     @attributes[:main    ]
        @multi_value.home_fax.should.equal @attributes[:home_fax]
        @multi_value.work_fax.should.equal @attributes[:work_fax]
        @multi_value.pager.should.equal    @attributes[:pager   ]
        @multi_value.work.should.equal     @attributes[:work    ]
        @multi_value.home.should.equal     @attributes[:home    ]
        @multi_value.other.should.equal    @attributes[:other   ]
      end

      it 'should give all the values in a list' do
        @multi_value.values.should == ["123-456-7890", "222-333-4444", "555-1212", "1-617-555-8000", "1-212-555-0000", "99-9999-9999", "alex@work.com", "alex@home.com", "alex@other.com"]
      end
    end

    describe 'setting each field' do
      before do
        @multi_value = AddressBook::MultiValue.new
      end

      it 'should be able to set the first name' do
        @multi_value.mobile =            '123456789'
        @multi_value.mobile.should.equal '123456789'
      end
      it 'should be able to set the iphone' do
        @multi_value.iphone =            '123456789'
        @multi_value.iphone.should.equal '123456789'
      end
      it 'should be able to set the main' do
        @multi_value.main =            '123456789'
        @multi_value.main.should.equal '123456789'
      end
      it 'should be able to set the home fax' do
        @multi_value.home_fax =            '123456789'
        @multi_value.home_fax.should.equal '123456789'
      end
      it 'should be able to set the work fax' do
        @multi_value.work_fax =            '123456789'
        @multi_value.work_fax.should.equal '123456789'
      end
      it 'should be able to set the pager' do
        @multi_value.pager =            '123456789'
        @multi_value.pager.should.equal '123456789'
      end
      it 'should be able to set the work' do
        @multi_value.work =            'a@work.com'
        @multi_value.work.should.equal 'a@work.com'
      end
      it 'should be able to set the home' do
        @multi_value.home =            'a@home.com'
        @multi_value.home.should.equal 'a@home.com'
      end
      it 'should be able to set the other' do
        @multi_value.other =            'a@other.com'
        @multi_value.other.should.equal 'a@other.com'
      end
    end
  end

  describe 'an existing multivalue' do
    before do
      @first_multi_value = AddressBook::MultiValue.new :mobile => '123-456-7890', :iphone => '99-8888888-7777777-66'
      @multi_value = AddressBook::MultiValue.new({:mobile => '987654321', :home_fax => '777-6666-4444'}, @first_multi_value.ab_multi_values)
    end

    it 'should ' do
      @multi_value.mobile.should == '987654321'
      @multi_value.iphone.should == '99-8888888-7777777-66'
      @multi_value.home_fax.should == '777-6666-4444'
    end
  end

describe 'method missing magic' do
  before do
    @multi_value = AddressBook::MultiValue.new
  end
  describe 'getters' do
    it 'should have a getter for each attribute' do
      @multi_value.getter?('mobile'  ).should.be truthy
      @multi_value.getter?('iphone'  ).should.be truthy
      @multi_value.getter?('main'    ).should.be truthy
      @multi_value.getter?('home_fax').should.be truthy
      @multi_value.getter?('work_fax').should.be truthy
      @multi_value.getter?('pager'   ).should.be truthy
      @multi_value.getter?('work'    ).should.be truthy
      @multi_value.getter?('home'    ).should.be truthy
      @multi_value.getter?('other'   ).should.be truthy
    end
    it 'should know what is not a getter' do
      @multi_value.getter?('nonesense').should.be falsey
      @multi_value.getter?('mobile='  ).should.be falsey
    end
  end
  describe 'setters' do
    it 'should have a setter for each attribute' do
      @multi_value.setter?('mobile='  ).should.be truthy
      @multi_value.setter?('iphone='  ).should.be truthy
      @multi_value.setter?('main='    ).should.be truthy
      @multi_value.setter?('home_fax=').should.be truthy
      @multi_value.setter?('work_fax=').should.be truthy
      @multi_value.setter?('pager='   ).should.be truthy
      @multi_value.setter?('work='    ).should.be truthy
      @multi_value.setter?('home='    ).should.be truthy
      @multi_value.setter?('other='   ).should.be truthy
    end
    it 'should know what is not a setter' do
      @multi_value.setter?('nonesense=').should.be falsey
      @multi_value.setter?('mobile'    ).should.be falsey
    end
  end
end

end

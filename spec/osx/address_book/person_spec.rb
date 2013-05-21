describe AddressBook::Person do
  describe 'new' do
    before do
      @data = new_alex
      @ab = AddressBook::AddrBook.new
      @alex = @ab.new_person(@data)
    end
    it 'should create but not save in the address book' do
      @alex.uid.should.not.be.nil
      @alex.should.be.new
      @alex.should.not.be.exists
    end
    it 'should have initial values' do
      @alex.first_name.should == 'Alex'
      @alex.last_name.should  == 'Testy'
      @alex.email_values.should == [@data[:emails][0][:value]]
    end
  end

  describe 'stuff' do
    before do
      @attributes = {
        :first_name=>'Alex',
        :middle_name=>'Q.',
        :last_name=>'Testy',
        :suffix => 'III',
        :nickname => 'Geekster',
        :job_title => 'Developer',
        :department => 'Development',
        :organization => 'The Company',
        :note => 'some important guy',
        # :mobile_phone => '123 456 7890', :office_phone => '987 654 3210',
        :phones => [
          {:label => 'mobile', :value => '123 456 7899'},
          {:label => 'office', :value => '987 654 3210'}
        ],
        # :email => unique_email,
        :emails => [
          {:label => 'work', :value => unique_email}
        ],
        :addresses => [
          {:label => 'home', :city => 'Dogpatch', :state => 'KY'}
        ],
        :urls => [
          { :label => 'home page', :value => "http://www.mysite.com/" },
          { :label => 'work', :value => 'http://dept.bigco.com/' },
          { :label => 'school', :value => 'http://state.edu/college' }
        ]
      }
    end

    describe 'a new person' do
      before do
        @ab = AddressBook::AddrBook.new
        @ab_person = @ab.new_person(@attributes)
      end

      it 'should not exist' do
        @ab_person.should.be.new
        @ab_person.should.not.be.exists
      end

      it 'should be able to get each of the single value fields' do
        @ab_person.first_name.should.equal   @attributes[:first_name  ]
        @ab_person.last_name.should.equal    @attributes[:last_name   ]
        @ab_person.middle_name.should.equal    @attributes[:middle_name   ]
        @ab_person.suffix.should.equal    @attributes[:suffix   ]
        @ab_person.nickname.should.equal    @attributes[:nickname   ]
        @ab_person.job_title.should.equal    @attributes[:job_title   ]
        @ab_person.department.should.equal   @attributes[:department  ]
        @ab_person.organization.should.equal @attributes[:organization]
        @ab_person.note.should.equal @attributes[:note]
        @ab_person.should.be.person?
      end

      it 'should get a value back for singular requests against multi-value attributes' do
        @ab_person.email.should.equal @attributes[:emails].first[:value]
        @ab_person.phone.should.equal @attributes[:phones].first[:value]
        @ab_person.url.should.equal @attributes[:urls].first[:value]
        @ab_person.address.should.equal @attributes[:addresses].first
      end

      # describe 'setting each field' do
      #   it 'should be able to set the first name' do
      #     @ab_person.first_name = 'new first name'
      #     @ab_person.first_name.should.equal 'new first name'
      #   end
      #   it 'should be able to set the last name' do
      #     @ab_person.last_name = 'new last name'
      #     @ab_person.last_name.should.equal 'new last name'
      #   end
      #   it 'should be able to set the job title' do
      #     @ab_person.job_title = 'new job title'
      #     @ab_person.job_title.should.equal 'new job title'
      #   end
      #   it 'should be able to set the department' do
      #     @ab_person.department = 'new department'
      #     @ab_person.department.should.equal 'new department'
      #   end
      #   it 'should be able to set the organization' do
      #     @ab_person.organization = 'new organization'
      #     @ab_person.organization.should.equal 'new organization'
      #   end

      #   it 'should be able to set the photo' do
      #     image = CIImage.emptyImage
      #     data = UIImagePNGRepresentation(UIImage.imageWithCIImage image)
      #     @ab_person.photo = data
      #     UIImagePNGRepresentation(@ab_person.photo).should.equal data
      #   end
      # end

      it 'should be able to count & get the phone numbers' do
        @ab_person.phones.size.should.equal 2
        @ab_person.phones.attributes.should.equal @attributes[:phones]
      end

      it 'should be able to count & get the emails' do
        @ab_person.emails.size.should.equal 1
        @ab_person.emails.attributes.should.equal @attributes[:emails]
      end

      it 'should be able to count & inspect the addresses' do
        @ab_person.addresses.count.should.equal 1
        @ab_person.addresses.attributes.should.equal @attributes[:addresses]
      end

      it 'should be able to count & inspect the URLs' do
        @ab_person.urls.count.should.equal 3
        @ab_person.urls.attributes.should.equal @attributes[:urls]
      end

    #   describe 'once saved' do
    #     before do
    #       @before_count = AddressBook.count
    #       @ab_person.save
    #     end
    #     after do
    #       @ab_person.delete!
    #     end

    #     it 'should no longer be new' do
    #       @ab_person.should.not.be.new_record
    #       @ab_person.should.be.exists
    #     end

    #     it "should increment the count" do
    #       AddressBook.count.should.equal @before_count+1
    #     end

    #     it 'should have scalar properties' do
    #       [:first_name, :middle_name, :last_name, :job_title, :department, :organization, :note].each do |attr|
    #         @ab_person.attributes[attr].should.equal @attributes[attr]
    #       end
    #     end

    #     it 'should have a composite name' do
    #       @ab_person.composite_name.should == 'Alex Q. Testy III'
    #     end

    #     it 'should be able to count the emails' do
    #       @ab_person.emails.size.should.equal 1
    #     end

    #     it 'should be able to count the addresses' do
    #       @ab_person.addresses.count.should.equal 1
    #     end

    #     it 'should be able to retrieve the addresses' do
    #       @ab_person.addresses.attributes.should.equal @attributes[:addresses]
    #     end
    #   end

    #   describe 'can be deleted' do
    #     before do
    #       @ab_person.save
    #       @ab_person.delete!
    #     end
    #     it 'after deletion it should no longer exist' do
    #       @ab_person.should.not.be.exists
    #       @ab_person.should.be.new_record
    #     end
    #   end
    # end

    # describe 'an existing person' do
    #   before do
    #     @orig_ab_person = AddressBook::Person.new(@attributes)
    #     @orig_ab_person.save
    #     @ab_person = AddressBook::Person.find_or_new_by_email(@attributes[:emails][0][:value])
    #   end
    #   after do
    #     @ab_person.delete!
    #   end

    #   it 'should know it is not new' do
    #     @ab_person.should.not.be.new_record
    #     @ab_person.should.be.exists
    #     @ab_person.first_name.should == 'Alex'
    #     @ab_person.department.should == 'Development'
    #   end

    #   it 'should not change ID' do
    #     @ab_person.uid.should.equal @orig_ab_person.uid
    #   end

    #   describe 'when updated' do
    #     before do
    #       @ab_person.first_name = 'New First Name'
    #       @ab_person.save
    #     end

    #     it 'should be able to get each of the single value fields' do
    #       @match = AddressBook::Person.find_by_email(@ab_person.email_values.first)
    #       @match.first_name.should == 'New First Name'
    #       @match.uid.should.equal @ab_person.uid
    #     end
    #   end
    end

    # describe "input with bad attributes" do
    #   before do
    #     @attributes[:junk] = 'this should be ignored'
    #     @attributes[:last_name] = nil
    #     @attributes[:urls] = [
    #       { :value => "http://www.mysite.com/" },
    #       { :label => 'work' },
    #       { :label => 'work', :url => 'http://state.edu/college' }
    #     ]
    #     @ab_person = AddressBook::Person.create(@attributes)
    #   end
    #   after do
    #     @ab_person.delete!
    #   end

    #   # entries with missing label should be OK
    #   # entries with missing value should be ignored
    #   # entries with illegal fields should raise an exception
    #   it "should save without errors" do
    #     @ab_person.should.be.exists
    #   end

    #   it "should have the expected values" do
    #     @ab_person.urls.count.should.equal 1
    #     urldata = [{:value => "http://www.mysite.com/", :label => ""}]
    #     @ab_person.urls.attributes.should.equal urldata
    #     @ab_person.attributes.keys.should.not.include?(:junk)
    #     @ab_person.last_name.should.equal nil
    #   end
    # end
  end
end

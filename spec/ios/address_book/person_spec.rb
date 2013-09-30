describe AddressBook::Person do
  before do
    @ab = AddressBook::AddrBook.new
  end

  describe 'ways of creating and finding people' do
    describe 'new' do
      before do
        @data = new_alex
        @alex = AddressBook::Person.new(@data)
      end
      it 'should create but not save in the address book' do
        @alex.should.be.new_record
        @alex.should.not.exists?
      end
      it 'should have initial values' do
        @alex.first_name.should == 'Alex'
        @alex.last_name.should  == 'Testy'
        @alex.email_values.should == [@data[:emails][0][:value]]
      end
      it 'should have a composite name' do
        @alex.composite_name.should == 'Alex Testy'
      end
    end

    describe 'existing' do
      before do
        @email = unique_email
        @alex = AddressBook::Person.create(new_alex(@email))
      end
      after do
        @alex.delete!
      end
      describe '.find_by_uid' do
        it 'should find match' do
          @alex.uid.should.not.be.nil
          alex = AddressBook::Person.find_by_uid @alex.uid
          alex.uid.should == @alex.uid
          alex.email_values.should.include? @email
          alex.first_name.should == 'Alex'
          alex.last_name.should  == 'Testy'
        end
      end
      describe '.find_all_by_email' do
        it 'should find matches' do
          alexes = AddressBook::Person.find_all_by_email @email
          alexes.should.not.be.empty
          alexes.each do |alex|
            alex.uid.should != nil
            alex.email_values.should.include? @email
            alex.first_name.should == 'Alex'
            alex.last_name.should  == 'Testy'
          end
        end
        it 'should give empty list when nothing matches' do
          alexes = AddressBook::Person.find_all_by_email unique_email
          alexes.should == []
        end
      end
      describe '.find_by_email' do
        it 'should find match' do
          alex = AddressBook::Person.find_by_email @email
          alex.uid.should.not.be.nil
          alex.email_values.should.include? @email
          alex.first_name.should == 'Alex'
          alex.last_name.should  == 'Testy'
        end
        it 'should give empty list when nothing matches' do
          alexes = AddressBook::Person.find_by_email unique_email
          alexes.should.be.nil
        end
      end
      describe '.where' do
        it 'should find matches' do
          alexes = AddressBook::Person.where(:email => @email)
          alexes.should.not.be.empty
          alexes.each do |alex|
            alex.uid.should != nil
            alex.email_values.should.include? @email
            alex.first_name.should == 'Alex'
            alex.last_name.should  == 'Testy'
          end
        end
        it 'should give empty list when nothing matches' do
          alexes = AddressBook::Person.where(:email => unique_email)
          alexes.should == []
        end
      end

      describe '.all' do
        it 'should have the person we created' do
          all_names = AddressBook::Person.all.map do |person|
            [person.first_name, person.last_name]
          end
          all_names.should.include? [@alex.first_name, @alex.last_name]
        end

        it 'should get bigger when we create another' do
          initial_people_count = AddressBook::Person.all.size
          @person = AddressBook::Person.create({:first_name => 'Alex2', :last_name=>'Rothenberg2'})
          AddressBook::Person.all.size.should == (initial_people_count + 1)
          @person.delete!
        end
      end
    end

    describe '.find_or_new_by_XXX - new or existing' do
      before do
        @email = unique_email
        @alex = AddressBook::Person.create(new_alex(@email))
      end
      after do
        @alex.delete!
      end

      it 'should find an existing person' do
        alex = AddressBook::Person.find_or_new_by_email(@email)
        alex.should.not.be.new_record
        alex.uid.should != nil
        alex.first_name.should == 'Alex'
        alex.last_name.should  == 'Testy'
        alex.emails.attributes.map{|r| r[:value]}.should == [@email]
      end
      it 'should return new person when no match found' do
        never_before_used_email = unique_email
        new_person = AddressBook::Person.find_or_new_by_email(never_before_used_email)
        new_person.should.be.new_record
        new_person.should.not.exists
        new_person.email_values.should == [never_before_used_email]
        new_person.first_name.should == nil
      end
    end
  end

  describe 'save' do
    before do
      @attributes = {
        :prefix => 'Mr.',
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
        ],
        :social_profiles => [
                             { service: 'FaceBook', username: 'testyman' },
                             { service: 'twitter', username: 'testwit' }
                            ]
      }
    end

    describe 'a new person' do
      before do
        @ab_person = AddressBook::Person.new(@attributes)
      end

      it 'should not be existing' do
        @ab_person.should.be.new_record
        @ab_person.should.not.be.exists
      end

      it 'should be able to get each of the single value fields' do
        @ab_person.first_name.should.equal   @attributes[:first_name  ]
        @ab_person.last_name.should.equal    @attributes[:last_name   ]
        @ab_person.middle_name.should.equal    @attributes[:middle_name   ]
        @ab_person.prefix.should.equal       @attributes[:prefix   ]
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

      describe 'setting each field' do
        it 'should be able to set the first name' do
          @ab_person.first_name = 'new first name'
          @ab_person.first_name.should.equal 'new first name'
        end
        it 'should be able to set the last name' do
          @ab_person.last_name = 'new last name'
          @ab_person.last_name.should.equal 'new last name'
        end
        it 'should be able to set the job title' do
          @ab_person.job_title = 'new job title'
          @ab_person.job_title.should.equal 'new job title'
        end
        it 'should be able to set the department' do
          @ab_person.department = 'new department'
          @ab_person.department.should.equal 'new department'
        end
        it 'should be able to set the organization' do
          @ab_person.organization = 'new organization'
          @ab_person.organization.should.equal 'new organization'
        end

        it 'should be able to set the photo' do
          image = CIImage.emptyImage
          data = UIImagePNGRepresentation(UIImage.imageWithCIImage image)
          @ab_person.photo = data
          UIImagePNGRepresentation(@ab_person.photo).should.equal data
        end
      end

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

      it 'should round-trip social profiles' do
        @ab_person.social_profiles.count.should.equal 2
        @ab_person.attributes[:social_profiles].should.equal @attributes[:social_profiles]
      end

      describe 'once saved' do
        before do
          @before_count = AddressBook.count
          @ab_person.save
        end
        after do
          @ab_person.delete!
        end

        it 'should no longer be new' do
          @ab_person.should.not.be.new_record
          @ab_person.should.be.exists
        end

        it "should increment the count" do
          AddressBook.count.should.equal @before_count+1
        end

        it 'should have scalar properties' do
          [:first_name, :middle_name, :last_name, :job_title, :department, :organization, :note].each do |attr|
            @ab_person.attributes[attr].should.equal @attributes[attr]
          end
        end

        it 'should have a composite name' do
          @ab_person.composite_name.should == 'Mr. Alex Q. Testy III'
        end

        it 'should be able to count the emails' do
          @ab_person.emails.size.should.equal 1
        end

        it 'should be able to count the addresses' do
          @ab_person.addresses.count.should.equal 1
        end

        it 'should be able to retrieve the addresses' do
          @ab_person.addresses.attributes.should.equal @attributes[:addresses]
        end
      end

      describe 'can be deleted' do
        before do
          @ab_person.save
          @ab_person.delete!
        end
        it 'after deletion it should no longer exist' do
          @ab_person.should.not.be.exists
          @ab_person.should.be.new_record
        end
      end
    end

    describe 'an existing person' do
      before do
        @orig_ab_person = AddressBook::Person.new(@attributes)
        @orig_ab_person.save
        @ab_person = AddressBook::Person.find_or_new_by_email(@attributes[:emails][0][:value])
      end
      after do
        @ab_person.delete!
      end

      it 'should know it is not new' do
        @ab_person.should.not.be.new_record
        @ab_person.should.be.exists
        @ab_person.first_name.should == 'Alex'
        @ab_person.department.should == 'Development'
      end

      it 'should not change ID' do
        @ab_person.uid.should.equal @orig_ab_person.uid
      end

      describe 'when updated' do
        before do
          @ab_person.first_name = 'New First Name'
          @ab_person.save
        end

        it 'should be able to get each of the single value fields' do
          @match = AddressBook::Person.find_by_email(@ab_person.email_values.first)
          @match.first_name.should == 'New First Name'
          @match.uid.should.equal @ab_person.uid
        end
      end
    end

    describe "input with bad attributes" do
      before do
        @attributes[:junk] = 'this should be ignored'
        @attributes[:last_name] = nil
        @attributes[:urls] = [
          { :value => "http://www.mysite.com/" },
          { :label => 'work' },
          { :label => 'work', :url => 'http://state.edu/college' }
        ]
        @ab_person = AddressBook::Person.create(@attributes)
      end
      after do
        @ab_person.delete!
      end

      # entries with missing label should be OK
      # entries with missing value should be ignored
      # entries with illegal fields should raise an exception
      it "should save without errors" do
        @ab_person.should.be.exists
      end

      it "should have the expected values" do
        @ab_person.urls.count.should.equal 1
        urldata = [{:value => "http://www.mysite.com/", :label => ""}]
        @ab_person.urls.attributes.should.equal urldata
        @ab_person.attributes.keys.should.not.include?(:junk)
        @ab_person.last_name.should.equal nil
      end
    end
  end

  describe "organization record" do
    before do
      @person = AddressBook::Person.new(
        :first_name => 'John',
        :last_name => 'Whorfin',
        :organization => 'Acme Inc.',
        :is_org => true,
        :note => 'big important company'
      )
    end

    it "should know that it is an organization" do
      @person.should.be.organization?
    end
  end

  describe 'method missing magic' do
    before do
      @person = AddressBook::Person.new
    end
    describe 'getters' do
      it 'should have a getter for each attribute' do
        @person.getter?('first_name'  ).should.be truthy
        @person.getter?('last_name'   ).should.be truthy
        @person.getter?('job_title'   ).should.be truthy
        @person.getter?('department'  ).should.be truthy
        @person.getter?('organization').should.be truthy
      end
      it 'should know what is not a getter' do
        @person.getter?('nonesense'        ).should.be falsey
        @person.getter?('first_name='      ).should.be falsey
        @person.getter?('find_all_by_email').should.be falsey
        @person.getter?('find_by_email'    ).should.be falsey
      end
    end
    describe 'setters' do
      it 'should have a setter for each attribute' do
        @person.setter?('first_name='  ).should.be truthy
        @person.setter?('last_name='   ).should.be truthy
        @person.setter?('job_title='   ).should.be truthy
        @person.setter?('department='  ).should.be truthy
        @person.setter?('organization=').should.be truthy
      end
      it 'should know what is not a setter' do
        @person.setter?('nonesense='       ).should.be falsey
        @person.setter?('first_name'       ).should.be falsey
        @person.setter?('find_all_by_email').should.be falsey
        @person.setter?('find_by_email'    ).should.be falsey
      end
      it 'should not have a setter for uid' do
        @person.setter?('uid=').should.be falsey
      end
    end
    describe 'all_finders' do
      it 'should have a finder for each attribute' do
        AddressBook::Person.all_finder?('find_all_by_first_name'  ).should.be truthy
        AddressBook::Person.all_finder?('find_all_by_last_name'   ).should.be truthy
        AddressBook::Person.all_finder?('find_all_by_job_title'   ).should.be truthy
        AddressBook::Person.all_finder?('find_all_by_department'  ).should.be truthy
        AddressBook::Person.all_finder?('find_all_by_organization').should.be truthy
      end
      it 'should know what is not a finder' do
        AddressBook::Person.all_finder?('nonesense'    ).should.be falsey
        AddressBook::Person.all_finder?('first_name'   ).should.be falsey
        AddressBook::Person.all_finder?('first_name='  ).should.be falsey
        AddressBook::Person.all_finder?('find_by_email').should.be falsey
      end
    end
    describe 'first_finders' do
      it 'should have a finder for each attribute' do
        AddressBook::Person.first_finder?('find_by_first_name'  ).should.be truthy
        AddressBook::Person.first_finder?('find_by_last_name'   ).should.be truthy
        AddressBook::Person.first_finder?('find_by_job_title'   ).should.be truthy
        AddressBook::Person.first_finder?('find_by_department'  ).should.be truthy
        AddressBook::Person.first_finder?('find_by_organization').should.be truthy
      end
      it 'should know what is not a finder' do
        AddressBook::Person.first_finder?('nonesense'        ).should.be falsey
        AddressBook::Person.first_finder?('first_name'       ).should.be falsey
        AddressBook::Person.first_finder?('first_name='      ).should.be falsey
        AddressBook::Person.first_finder?('find_all_by_email').should.be falsey
      end
    end
  end

  describe "sorting" do
    before do
      @ab.people.each(&:delete!)

      @p1 = @ab.create_person({:first_name => 'Bob', :last_name => 'Edwards'}).uid
      @p2 = @ab.create_person({:first_name => 'Doris', :last_name => 'Channing'}).uid
      @p3 = @ab.create_person({:first_name => 'Anne', :last_name => 'Brown'}).uid
      @p4 = @ab.create_person({:first_name => 'Eddie', :last_name => 'Anderson'}).uid
      @p5 = @ab.create_person({:first_name => 'Carol', :last_name => 'Dolittle'}).uid
    end

    it "should sort on last name using OS sort" do
      @ab.people(ordering: KABPersonSortByLastName).map(&:uid).should.equal [@p4, @p3, @p2, @p5, @p1]
    end
    it "should support last-name sort in Person#all" do
      AddressBook::Person.all(ordering: KABPersonSortByLastName).map(&:uid).should.equal [@p4, @p3, @p2, @p5, @p1]
    end

    it "should sort on first name using OS sort" do
      @ab.people(ordering: KABPersonSortByFirstName).map(&:uid).should.equal [@p3, @p1, @p5, @p2, @p4]
    end
    it "should support first-name sort in Person#all" do
      AddressBook::Person.all(ordering: KABPersonSortByFirstName).map(&:uid).should.equal  [@p3, @p1, @p5, @p2, @p4]
    end

    it "should support a custom sort order" do
      ordered = @ab.people { |p| p.last_name[1] }.map(&:uid)
      ordered.should.equal [@p1, @p2, @p4, @p5, @p3]
    end
  end
end

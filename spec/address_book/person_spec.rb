describe AddressBook::Person do
  before do
    @ab = AddressBook::AddrBook.new
  end
  describe 'ways of creating and finding people' do
    describe 'new' do
      before do
        @data = new_alex
        @alex = @ab.new_person(@data)
      end
      it 'should create but not save in the address book' do
        @alex.should.be.new_record
      end
      it 'should have no mod date' do
        @alex.modification_date.should.be.nil
      end
      it 'should have initial values' do
        @alex.first_name.should == 'Alex'
        @alex.last_name.should  == 'Testy'
        @alex.email_values.should == [@data[:emails][0][:value]]
        @alex.email.should == @data[:emails][0][:value]
      end
      it "should round-trip attributes without loss" do
        @alex.attributes.should.equal @data
      end
      it 'should have a composite name' do
        @alex.composite_name.should == 'Alex Testy'
      end
    end

    describe 'existing' do
      before do
        @email = unique_email
        @alex = @ab.create_person(new_alex(@email))
      end
      after do
        @alex.delete!
      end
      it 'should have a mod date' do
        @alex.modification_date.should.not.be.nil
      end
      describe '.find_by_uid' do
        it 'should find match' do
          alex = @ab.person(@alex.uid)
          alex.uid.should == @alex.uid
          alex.email_values.should.include? @email
          alex.first_name.should == 'Alex'
          alex.last_name.should  == 'Testy'
          alex.attributes.should.equal @alex.attributes
        end
      end
      describe '.find_all_by_email' do
        it 'should find matches' do
          alexes = AddressBook::Person.find_all_by_email @email
          alexes.should.not.be.empty
          alexes.each do |alex|
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
          all_names = @ab.people.map do |person|
            [person.first_name, person.last_name]
          end
          all_names.should.include? [@alex.first_name, @alex.last_name]
        end

        it 'should get bigger when we create another' do
          initial_people_count = @ab.people.size
          @person = @ab.create_person({:first_name => 'Alex2', :last_name=>'Rothenberg2'})
          @ab.people.size.should == (initial_people_count + 1)
          @person.delete!
        end
      end
    end

    describe '.find_or_new_by_XXX - new or existing' do
      before do
        @email = unique_email
        @alex = @ab.create_person(new_alex(@email))
      end
      after do
        @alex.delete!
      end

      it 'should find an existing person' do
        alex = AddressBook::Person.find_or_new_by_email(@email)
        alex.should.not.be.new_record
        alex.first_name.should == 'Alex'
        alex.last_name.should  == 'Testy'
        alex.emails.attributes.map{|r| r[:value]}.should == [@email]
      end
      it 'should return new person when no match found' do
        never_before_used_email = unique_email
        new_person = AddressBook::Person.find_or_new_by_email(never_before_used_email)
        new_person.should.be.new_record
        new_person.email_values.should == [never_before_used_email]
        new_person.first_name.should == nil
      end
    end
  end

  describe 'save' do
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
        @ab_person = @ab.new_person(@attributes)
      end

      it 'should not be existing' do
        @ab_person.should.be.new_record
        @ab_person.should.not.be.exists
        @ab_person.modification_date.should.be.nil
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

      describe 'once saved' do
        before do
          @before = Time.now
          @before_count = AddressBook.count
          @ab_person.save
        end
        after do
          @ab_person.delete!
        end

        it 'should no longer be new' do
          @ab_person.should.not.be.new_record
          @ab_person.should.be.exists
          @ab_person.modification_date.should.not.be.nil
          should.satisfy {@ab_person.modification_date > @before}
        end

        it "should increment the count" do
          AddressBook.count.should.equal @before_count+1
        end

        it 'should round-trip all attributes without loss' do
          @ab_person.attributes.should.equal @attributes
        end

        it 'should have scalar properties' do
          [:first_name, :middle_name, :last_name, :job_title, :department, :organization, :note].each do |attr|
            @ab_person.send(attr).should.equal @attributes[attr]
          end
        end

        it 'should have a composite name' do
          @ab_person.composite_name.should == 'Alex Q. Testy III'
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

      describe 'once deleted' do
        before do
          @ab_person.save
          @ab_person.delete!
        end
        it 'should no longer exist' do
          @ab_person.should.not.be.exists
          # @ab_person.should.be.new_record
        end
      end
    end

    describe 'an existing person' do
      before do
        @orig_ab_person = @ab.create_person(@attributes)
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
        @ab_person = @ab.create_person(@attributes)
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
      @person = @ab.new_person(
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
      @person = @ab.new_person({})
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

  describe "multiple emails/phone #'s handling" do
    it "should accept multiple emails/phone #'s as array of strings for new records" do
      person = @ab.new_person(
        :first_name => 'Ashish',
        :last_name => 'Upadhyay',
        :email => ['a@mail.com','a@mail.com','a@mail.com'],
        :phones => ['1212999222','1212999333','1212999444'],
      )
      person.should.be.new_record
    end
    it "should accept multiple emails/phone #'s as array of hashes for new records" do
      person = @ab.new_person(
        :first_name => 'Ashish',
        :last_name => 'Upadhyay',
        :email => [{ :value => 'a@mail.com' } , { :value => 'a@mail.com' } , { :value => 'a@mail.com' } ] ,
        :phones => [{ :value => '1212999222' } , { :value => '1212999333' } , { :value => '1212999444' } ] ,
      )
      person.should.be.new_record
    end
    it "should accept multiple emails/phone #'s as array of combination of strings or hashes for new records" do
      person = @ab.new_person(
        :first_name => 'Ashish',
        :last_name => 'Upadhyay',
        :email => [ { :value => 'a@mail.com' } , 'a@mail.com' , { :value => 'a@mail.com', :label => 'Office'}] , 
        :phones => [ '1212999222' ,  { :value => '1212999333', :label => 'Personal' } , { :value => '1212999444' } ] , 
      )
      person.should.be.new_record
    end
  end
end

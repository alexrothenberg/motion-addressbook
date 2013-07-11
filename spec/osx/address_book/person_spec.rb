describe AddressBook::Person do
  before do
    @alex_data = {
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
      :phones => [
        {:label => 'mobile', :value => '123 456 7899'},
        {:label => 'office', :value => '987 654 3210'}
      ],
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
      @the_person = @ab.new_person(@alex_data)
    end

    it 'should not exist' do
      @the_person.should.be.new
      @the_person.should.not.be.exists
    end

    it 'should be able to get each of the single value fields' do
      @the_person.first_name.should.equal   @alex_data[:first_name]
      @the_person.last_name.should.equal    @alex_data[:last_name]
      @the_person.middle_name.should.equal  @alex_data[:middle_name]
      @the_person.prefix.should.equal       @alex_data[:prefix]
      @the_person.suffix.should.equal       @alex_data[:suffix]
      @the_person.nickname.should.equal     @alex_data[:nickname]
      @the_person.job_title.should.equal    @alex_data[:job_title]
      @the_person.department.should.equal   @alex_data[:department]
      @the_person.organization.should.equal @alex_data[:organization]
      @the_person.note.should.equal         @alex_data[:note]
      @the_person.should.be.person?
    end

    it 'should get a value back for singular requests against multi-value attributes' do
      @the_person.email.should.equal @alex_data[:emails].first[:value]
      @the_person.phone.should.equal @alex_data[:phones].first[:value]
      @the_person.url.should.equal @alex_data[:urls].first[:value]
      @the_person.address.should.equal @alex_data[:addresses].first
    end

    # describe 'setting each field' do
    #   it 'should be able to set the first name' do
    #     @the_person.first_name = 'new first name'
    #     @the_person.first_name.should.equal 'new first name'
    #   end
    #   it 'should be able to set the last name' do
    #     @the_person.last_name = 'new last name'
    #     @the_person.last_name.should.equal 'new last name'
    #   end
    #   it 'should be able to set the job title' do
    #     @the_person.job_title = 'new job title'
    #     @the_person.job_title.should.equal 'new job title'
    #   end
    #   it 'should be able to set the department' do
    #     @the_person.department = 'new department'
    #     @the_person.department.should.equal 'new department'
    #   end
    #   it 'should be able to set the organization' do
    #     @the_person.organization = 'new organization'
    #     @the_person.organization.should.equal 'new organization'
    #   end

    #   it 'should be able to set the photo' do
    #     image = CIImage.emptyImage
    #     data = UIImagePNGRepresentation(UIImage.imageWithCIImage image)
    #     @the_person.photo = data
    #     UIImagePNGRepresentation(@the_person.photo).should.equal data
    #   end
    # end

    it 'should be able to count & get the phone numbers' do
      @the_person.phones.size.should.equal 2
      @the_person.phones.attributes.should.equal @alex_data[:phones]
    end

    it 'should be able to count & get the emails' do
      @the_person.emails.size.should.equal 1
      @the_person.emails.attributes.should.equal @alex_data[:emails]
    end

    it 'should be able to count & inspect the addresses' do
      @the_person.addresses.count.should.equal 1
      @the_person.addresses.attributes.should.equal @alex_data[:addresses]
    end

    it 'should be able to count & inspect the URLs' do
      @the_person.urls.count.should.equal 3
      @the_person.urls.attributes.should.equal @alex_data[:urls]
    end

    describe 'once saved' do
      before do
        @before_count = @ab.count
        @the_person.save
      end
      after do
        @the_person.delete!
      end

      it 'should no longer be new' do
        @the_person.should.not.be.new
        @the_person.should.be.exists
      end

      it "should increment the count" do
        @ab.count.should.equal @before_count+1
      end

      it 'should have scalar properties' do
        [:first_name, :middle_name, :last_name, :job_title, :department, :organization, :note].each do |attr|
          @the_person.attributes[attr].should.equal @alex_data[attr]
        end
      end

      it 'should be able to count the emails' do
        @the_person.emails.size.should.equal 1
      end

      it 'should be able to count the addresses' do
        @the_person.addresses.count.should.equal 1
      end

      it 'should be able to retrieve the addresses' do
        @the_person.addresses.attributes.should.equal @alex_data[:addresses]
      end

      describe '...and updated' do
        before do
          @id_before = @the_person.uid
          @the_person.first_name = 'New First Name'
          @the_person.save
        end

        it 'should not change ID' do
          @the_person.uid.should.equal @id_before
        end
      end
    end

    describe 'after save & delete' do
      before do
        @the_person.save
        @the_person.delete!
      end
      it 'should no longer exist' do
        @the_person.should.not.be.exists
        @the_person.should.be.new
      end
    end
  end
end

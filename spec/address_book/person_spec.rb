describe AddressBook::Person do
  describe '.all' do
    before do
      @person = AddressBook::Person.create({:first_name => 'Alex', :last_name=>'Rothenberg'})
    end
    it 'should have the person we created' do
      all_names = AddressBook::Person.all.map do |person|
        [person.first_name, person.last_name]
      end
      all_names.should.include? ['Alex', 'Rothenberg'] 
    end
    
    it 'should get bigger when we create another' do 
      initial_people_count = AddressBook::Person.all.size
      @person = AddressBook::Person.create({:first_name => 'Alex2', :last_name=>'Rothenberg2'})
      AddressBook::Person.all.size.should == (initial_people_count + 1)
    end
  end

  describe 'save' do
    before do
      unique_email = "alex_#{Time.now.to_i}@example.com"
      @attributes = {:first_name=>'Alex', :last_name=>'Testy',
                     :job_title => 'Developer', :department => 'Development', :organization => 'The Company',
                     :mobile_phone => '123 456 7890', :office_phone => '987 654 3210',
                     :email => unique_email
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
        @ab_person.job_title.should.equal    @attributes[:job_title   ]
        @ab_person.department.should.equal   @attributes[:department  ]
        @ab_person.organization.should.equal @attributes[:organization]
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

        it 'should be able to set the phot' do
          image = CIImage.emptyImage
          data = UIImagePNGRepresentation(UIImage.imageWithCIImage image)
          @ab_person.photo = data
          UIImagePNGRepresentation(@ab_person.photo).should.equal data
        end

      end

      it 'should be able to get the phone numbers' do
        @ab_person.phone_number_values.should.equal [@attributes[:mobile_phone], @attributes[:office_phone] ]
      end

      it 'should be able to get the emails' do
        @ab_person.email_values.should.equal [@attributes[:email] ]
      end
      describe 'saving' do
        before do
          @ab_person.save
        end
        it 'after saving it should not be existing' do
          @ab_person.should.not.be.new_record
          @ab_person.should.be.exists
        end
      end
    end

    describe 'updating an existing person' do
      before do
        AddressBook::Person.new(@attributes).save
        @attributes[:job_title   ] = 'i got promoted'
        @attributes[:office_phone] = '111 222 3333'
        # @attributes[:department  ] = nil
        @ab_person = AddressBook::Person.new(@attributes)
      end

      it 'should know it is not new' do
        @ab_person.should.not.be.new_record
        @ab_person.should.be.exists
        @ab_person.department.should == 'Development'
      end

      describe 'updating' do
        before do
          @ab_person.save
          @new_ab_person = AddressBook::Person.new :first_name=>@attributes[:first_name], :email => @attributes[:email]
        end
        it 'should be able to get each of the single value fields' do
          @new_ab_person.first_name.should.equal   @attributes[:first_name  ]
          @new_ab_person.last_name.should.equal    @attributes[:last_name   ]
          @new_ab_person.job_title.should.equal    @attributes[:job_title   ]
          @new_ab_person.department.should.equal   @attributes[:department  ]
          @new_ab_person.organization.should.equal @attributes[:organization]
        end
        it 'should be able to get the phone numbers (we never delete and just add - not sure if this is "right")' do
          @new_ab_person.phone_number_values.should.equal [@attributes[:mobile_phone], '987 654 3210', @attributes[:office_phone]]
        end

        it 'should be able to get the emails' do
          @new_ab_person.email_values.should.equal [@attributes[:email] ]
        end
      end

    end

  end

end

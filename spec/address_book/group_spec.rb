describe AddressBook::Group do
  before do
    @ab = AddressBook::AddrBook.new
  end

  describe 'an empty group' do
    before do
      @group = @ab.new_group({:name => 'Test Group', :members => []})
    end

    describe 'before saving' do
      it "should have a name" do
        @group.name.should.equal 'Test Group'
      end

      it "should be empty" do
        @group.members.should.be.empty
        @group.size.should.equal 0
      end

      it "should be new" do
        @group.should.be.new
      end
    end

    describe 'after saving' do
      before do
        @group.save
      end

      it "should have a name" do
        @group.name.should.equal 'Test Group'
      end

      it "should be empty" do
        @group.members.should.be.empty
        @group.size.should.equal 0
      end

      it "should not be new" do
        @group.should.not.be.new
      end
    end
  end

  describe 'a group with members' do
    before do
      p1 = AddressBook::Person.create(:attributes => {:first_name => 'Alice', :emails => [{:label => 'home', :value => 'alice@example.com'}]})
      p2 = AddressBook::Person.create(:attributes => {:first_name => 'Bob', :emails => [{:label => 'home', :value => 'bob@example.com'}]})
      @group = @ab.new_group({:name => 'Test Group', :members => [p1, p2]})
      @group.save
    end

    it "should have 2 members" do
      @group.size.should.equal 2
    end

    it "should have the expected members" do
      @group.members.map {|person| person.first_name}.should.equal ['Alice', 'Bob']
    end
  end

  # TODO: nested groups
end

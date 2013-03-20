describe AddressBook::Group do
  before do
    @ab = AddressBook::AddrBook.new
  end

  describe 'an empty group' do
    before do
      @group = @ab.new_group(:name => 'Test Group')
    end
    after do
      @group.delete!
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

  describe 'a group with members' do
    before do
      @p1 = @ab.new_person({:first_name => 'Alice', :emails => [{:label => 'home', :value => 'alice@example.com'}]})
      @p1.save
      @p2 = @ab.new_person({:first_name => 'Bob', :emails => [{:label => 'home', :value => 'bob@example.com'}]})
      @p2.save
      @group = @ab.new_group(:name => 'Test Group')
      @group << @p1
      @group << @p2
      @group.save
    end
    after do
      @group.delete!
      @p1.delete!
      @p2.delete!
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

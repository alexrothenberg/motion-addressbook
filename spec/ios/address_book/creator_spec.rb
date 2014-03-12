describe AddressBook::Creator do
  before do
    @ab = AddressBook::AddrBook.new
    @person = @ab.create_person(first_name: 'Colin')
    @ab_person = @person.ab_person
  end

  after do
    @person.delete!
  end

  describe 'IOS UI for creating an entry' do
    before do
      @created_person = :not_set
      @picker = @ab.creator(animated: false) do |person|
        @created_person = person
      end
    end

    it 'should yield the created person' do
      @picker.newPersonViewController(nil, didCompleteWithNewPerson: @ab_person)
      @created_person.should.not == nil
      @created_person.should.be.kind_of?(AddressBook::Person)
      @created_person.first_name.should == 'Colin'
    end

    it 'should yield nil if canceled' do
      @created_person.should == :not_set
      @picker.newPersonViewController(nil, didCompleteWithNewPerson: nil)
      @created_person.should == nil
    end
  end
end

describe AddressBook::Picker do
  describe 'IOS UI for finding people' do
    before do
      @selected_person = nil
      @picker = AddressBook.pick do |person|
        @selected_person = person
      end
    end

    it 'should yield the selected person' do
      ab_person = AddressBook::Person.new(first_name: 'Colin').ab_person
      @picker.peoplePickerNavigationController(@picker_nav_controller, shouldContinueAfterSelectingPerson: ab_person)
      @selected_person.should.not == nil
      @selected_person.first_name.should == 'Colin'
    end

    it 'should yield the selected person' do
      property = :some_property
      id = :some_id
      ab_person = AddressBook::Person.new(first_name: 'Colin').ab_person
      @picker.peoplePickerNavigationController(@picker_nav_controller, shouldContinueAfterSelectingPerson: ab_person, property:property, identifier:id)
      @selected_person.should.not == nil
      @selected_person.first_name.should == 'Colin'
    end

    it 'should yield nil when cancelled' do
      ab_person = AddressBook::Person.new(first_name: 'Colin').ab_person
      @picker.peoplePickerNavigationControllerDidCancel(@picker_nav_controller)
      @selected_person.should == nil
    end
  end
end

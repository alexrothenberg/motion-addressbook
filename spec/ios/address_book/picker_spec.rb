describe AddressBook::Picker do
  describe 'IOS UI for finding people' do
    before do
      @ab = AddressBook::AddrBook.new
      @colin = @ab.create_person(first_name: 'Colin')
      @ab_person = @colin.ab_person
      @selected_person = nil
      @picker = @ab.picker(animated: false) do |person|
        @selected_person = person
        resume
      end
    end

    after do
      @colin.delete!
      @picker.hide(animated: false)
    end

    it 'should yield the selected person' do
      @picker.peoplePickerNavigationController(@picker_nav_controller, shouldContinueAfterSelectingPerson: @ab_person) if UIDevice.currentDevice.systemVersion < "8.0"
      @picker.peoplePickerNavigationController(@picker_nav_controller, didSelectPerson: @ab_person) if UIDevice.currentDevice.systemVersion >= "8.0"
      wait 5 {
        @selected_person.should.not == nil
        @selected_person.first_name.should == 'Colin'
      }
    end

    it 'should yield the selected person' do
      property = :some_property
      id = :some_id
      @picker.peoplePickerNavigationController(@picker_nav_controller, shouldContinueAfterSelectingPerson: @ab_person, property:property, identifier:id) if UIDevice.currentDevice.systemVersion < "8.0"
      @picker.peoplePickerNavigationController(@picker_nav_controller, didSelectPerson: @ab_person, property:property, identifier:id) if UIDevice.currentDevice.systemVersion >= "8.0"
      wait 5 {
        @selected_person.should.not == nil
        @selected_person.first_name.should == 'Colin'
      }
    end

    it 'should yield nil when cancelled' do
      @picker.peoplePickerNavigationControllerDidCancel(@picker_nav_controller)
      wait 5 {
        @selected_person.should == nil
      }
    end
  end
end

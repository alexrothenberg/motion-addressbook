# I don't know how to test a class wrapping a controller like this yet

describe AddressBook::Picker do
#   describe 'IOS UI for finding people' do
#     before do
#       @ab = AddressBook::AddrBook.new
#       @colin = AddressBook::Person.new(first_name: 'Colin')
#       @ab_person = @colin.ab_person
#       @selected_person = nil
#       @picker = @ab.picker do |person|
#         @selected_person = person
#       end
#     end
#
#     after do
#       @colin.delete!
#     end
#
#     it 'should yield the selected person' do
#       @picker.peoplePickerNavigationController(@picker_nav_controller, shouldContinueAfterSelectingPerson: @ab_person)
#       @selected_person.should.not == nil
#       @selected_person.first_name.should == 'Colin'
#     end
#
#     it 'should yield the selected person' do
#       property = :some_property
#       id = :some_id
#       @picker.peoplePickerNavigationController(@picker_nav_controller, shouldContinueAfterSelectingPerson: @ab_person, property:property, identifier:id)
#       @selected_person.should.not == nil
#       @selected_person.first_name.should == 'Colin'
#     end
#
#     it 'should yield nil when cancelled' do
#       @picker.peoplePickerNavigationControllerDidCancel(@picker_nav_controller)
#       @selected_person.should == nil
#     end
#   end
end

module AddressBook
  class Picker
    class << self
      def show &after
        raise "Cannot show two Pickers" if @showing

        @delegate ||= self.new
        @after = after
        @showing = true

        people_picker_ctlr = ABPeoplePickerNavigationController.alloc.init
        people_picker_ctlr.peoplePickerDelegate = @delegate
        UIApplication.sharedApplication.keyWindow.rootViewController.presentViewController(people_picker_ctlr, animated:true, completion:nil)

        return view_ctlr
      end

      def hide(ab_person)
        person = ab_person ? AddressBook::Person.new({}, ab_person) : nil

        UIApplication.sharedApplication.keyWindow.rootViewController.dismissViewControllerAnimated(true, completion:lambda{
          @after.call(person) if @after
          @showing = nil
        })
      end
    end

    def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person)
      self.class.hide(ab_person)
      false
    end

    def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person, property:property, identifier:id)
      self.class.hide(ab_person)
      false
    end

    def peoplePickerNavigationControllerDidCancel(people_picker)
      self.class.hide(nil)
    end
  end
end

module AddressBook
  module_function
  def pick &after
    AddressBook::Picker.show &after
  end
end


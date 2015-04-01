module AddressBook
  class Picker
    class << self
      attr_accessor :showing
    end
    def self.show(options={}, &after)
      raise "Cannot show two Pickers" if showing?
      @picker = self.new(options[:ab] || AddressBook::AddrBook.instance, &after)
      @picker.show options
      @picker
    end

    def self.showing?
      !!showing
    end

    def initialize(ab, &after)
      @ab = ab
      @after = after
    end

    def show(options)
      self.class.showing = true

      @people_picker_ctlr = ABPeoplePickerNavigationController.alloc.init
      @people_picker_ctlr.peoplePickerDelegate = self

      @presenter = options.fetch :presenter, UIApplication.sharedApplication.keyWindow.rootViewController
      @animated = options.fetch :animated, true
      @presenter.presentViewController(@people_picker_ctlr, animated: @animated, completion: nil)
    end

    def hide(ab_person=nil)
      person = ab_person && @ab.person(ABRecordGetRecordID(ab_person))

      @presenter.dismissViewControllerAnimated(@animated, completion: lambda do
          @after.call(person) if @after
          self.class.showing = false
        end)
    end

    def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person)
      puts "peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person)" 
      hide(ab_person)
      false
    end

    def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person, property:property, identifier:id)
      puts "peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person, property:property, identifier:id)"
      hide(ab_person)
      false
    end

    def peoplePickerNavigationControllerDidCancel(people_picker)
      puts "peoplePickerNavigationControllerDidCancel(people_picker)"
      hide
    end

  end
end

module AddressBook
  class Creator
    class << self
      attr_accessor :showing
    end
    def self.show(options={}, &after)
      raise "Cannot show two Pickers" if showing?
      @creator = self.new(options[:ab], &after)
      @creator.show options
      @creator
    end

    def self.showing?
      !!showing
    end

    def initialize(ab, &after)
      @ab = ab
      @after = after
    end

    def show(options={})
      self.class.showing = true

      @new_person_ctlr = ABNewPersonViewController.alloc.init
      @new_person_ctlr.newPersonViewDelegate = self

      @presenter = options.fetch :presenter, UIApplication.sharedApplication.keyWindow.rootViewController
      @animated = options.fetch :animated, true
      @presenter.presentViewController(@new_person_ctlr, animated: @animated, completion: nil)
    end

    def hide(ab_person=nil)
      person = ab_person && @ab.person(ABRecordGetRecordID(ab_person))

      @presenter.dismissViewControllerAnimated(@animated, completion: lambda do
        @after.call(person) if @after
        self.class.showing = false
      end)
    end

    def newPersonViewController(new_person_ctlr, didCompleteWithNewPerson: ab_person)
      hide(ab_person)
    end

  end
end
